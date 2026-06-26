module Admin
  class BaseController < ApplicationController
    before_action :authenticate_admin!

    private

    def authenticate_admin!
      username = ENV["ADMIN_USERNAME"]
      password = ENV["ADMIN_PASSWORD"]

      if username.blank? || password.blank?
        return if Rails.env.development?

        head :not_found
        return
      end

      authenticate_or_request_with_http_basic("Admin") do |given_username, given_password|
        secure_compare(given_username, username) &&
          secure_compare(given_password, password)
      end
    end

    def secure_compare(given_value, expected_value)
      ActiveSupport::SecurityUtils.secure_compare(
        secure_digest(given_value),
        secure_digest(expected_value)
      )
    end

    def secure_digest(value)
      Digest::SHA256.hexdigest(value.to_s)
    end
  end
end
