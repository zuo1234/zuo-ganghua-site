class ChatsController < ApplicationController
  wrap_parameters false

  MAX_MESSAGE_LENGTH = 4_000
  MAX_HISTORY_MESSAGES = 10

  def show; end

  def messages
    message = chat_params[:message].to_s.strip
    if message.blank?
      render json: { error: "请输入一条消息。" }, status: :unprocessable_entity
      return
    end

    if message.length > MAX_MESSAGE_LENGTH
      render json: { error: "单条消息不能超过 #{MAX_MESSAGE_LENGTH} 个字符。" }, status: :unprocessable_entity
      return
    end

    unless AiChat::Client.enabled?
      render json: { error: "AI 对话尚未配置。请在服务器设置 OPENAI_API_KEY。" }, status: :service_unavailable
      return
    end

    unless AiChat::RateLimiter.new.allowed?(request.remote_ip)
      render json: { error: "请求过于频繁，请稍后再试。" }, status: :too_many_requests
      return
    end

    reply = AiChat::Client.new.reply(message: message, history: normalized_history)
    render json: { message: reply }
  rescue AiChat::Client::ProviderError => error
    Rails.logger.warn("[ai_chat] provider error: #{error.message}")
    render json: { error: "AI 服务暂时不可用，请稍后重试。" }, status: :bad_gateway
  rescue AiChat::Client::ConfigurationError => error
    Rails.logger.warn("[ai_chat] configuration error: #{error.message}")
    render json: { error: "AI 对话尚未配置。请在服务器设置 OPENAI_API_KEY。" }, status: :service_unavailable
  end

  private

  def chat_params
    params.permit(:message, history: [:role, :content])
  end

  def normalized_history
    Array(chat_params[:history]).filter_map do |entry|
      role = entry[:role].to_s
      content = entry[:content].to_s.strip

      next unless %w[user assistant].include?(role) && content.present?

      { role: role, content: content[0, MAX_MESSAGE_LENGTH] }
    end.last(MAX_HISTORY_MESSAGES)
  end
end
