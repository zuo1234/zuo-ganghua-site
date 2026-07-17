require "openai"

module AiChat
  class Client
    DEFAULT_API_BASE_URL = "https://vibe.soyoung.com/".freeze
    DEFAULT_MODEL = "gpt-5.6-terra".freeze
    MAX_OUTPUT_TOKENS = 700
    REQUEST_TIMEOUT = 60
    SYSTEM_INSTRUCTIONS = <<~INSTRUCTIONS.freeze
      You are the concise, thoughtful assistant for Zuogh's personal website.
      Answer in Chinese unless the visitor asks for another language.
      You can help with Ruby, Rails, Golang, backend engineering, technical writing,
      and the public content of this site. Do not claim access to private data,
      production systems, or information that is not present in the conversation.
      State uncertainty plainly and keep answers practical.
    INSTRUCTIONS

    class ConfigurationError < StandardError; end
    class ProviderError < StandardError; end

    def self.enabled?
      ENV.fetch("AI_CHAT_ENABLED", "true").to_s.downcase != "false" && ENV["OPENAI_API_KEY"].present?
    end

    def initialize(
      api_key: ENV["OPENAI_API_KEY"],
      model: ENV.fetch("OPENAI_MODEL", DEFAULT_MODEL),
      api_base_url: ENV.fetch("OPENAI_API_BASE_URL", DEFAULT_API_BASE_URL),
      request_timeout: ENV.fetch("OPENAI_REQUEST_TIMEOUT", REQUEST_TIMEOUT).to_i
    )
      @api_key = api_key.to_s
      @model = model.to_s
      @api_base_url = api_base_url.to_s
      @request_timeout = [request_timeout, 1].max
    end

    def reply(message:, history: [])
      raise ConfigurationError, "OPENAI_API_KEY is missing" if @api_key.blank?
      raise ConfigurationError, "OPENAI_MODEL is missing" if @model.blank?

      response = openai_client.responses.create(parameters: request_payload(message, history))
      text = extract_output_text(response)
      raise ProviderError, "OpenAI returned an empty response" if text.blank?

      text
    rescue Faraday::Error, OpenAI::Error => error
      raise ProviderError, error.message
    end

    private

    def openai_client
      @openai_client ||= OpenAI::Client.new(
        access_token: @api_key,
        uri_base: @api_base_url,
        request_timeout: @request_timeout,
        log_errors: false
      )
    end

    def request_payload(message, history)
      {
        model: @model,
        instructions: SYSTEM_INSTRUCTIONS,
        input: conversation_transcript(message, history),
        max_output_tokens: MAX_OUTPUT_TOKENS
      }
    end

    def conversation_transcript(message, history)
      entries = history.map do |entry|
        speaker = entry[:role].to_s == "assistant" ? "Assistant" : "User"
        "#{speaker}: #{entry[:content]}"
      end

      entries << "User: #{message}"
      entries.join("\n\n")
    end

    def extract_output_text(payload)
      raise ProviderError, "OpenAI returned an invalid response" unless payload.is_a?(Hash)

      text = payload["output_text"].to_s.strip
      return text if text.present?

      payload.fetch("output", []).filter_map do |item|
        next unless item["type"] == "message"

        item.fetch("content", []).filter_map do |content|
          content["text"] if content["type"] == "output_text"
        end.join
      end.join("\n").strip
    end
  end
end
