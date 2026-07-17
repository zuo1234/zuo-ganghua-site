require "digest"

module AiChat
  class RateLimiter
    DEFAULT_LIMIT = 12
    WINDOW = 5.minutes

    def initialize(cache: Rails.cache, limit: ENV.fetch("AI_CHAT_RATE_LIMIT", DEFAULT_LIMIT).to_i, window: WINDOW)
      @cache = cache
      @limit = [limit, 1].max
      @window = window
    end

    def allowed?(identifier)
      key = "ai_chat/rate_limit/#{Digest::SHA256.hexdigest(identifier.to_s)}"
      current_count = @cache.read(key).to_i
      return false if current_count >= @limit

      @cache.write(key, current_count + 1, expires_in: @window)
      true
    end
  end
end
