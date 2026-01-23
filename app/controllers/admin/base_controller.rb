module Admin
  class BaseController < ApplicationController
    http_basic_authenticate_with(
      name: Rails.application.credentials.dig(:admin, :username) || ENV.fetch("ADMIN_USERNAME", "admin"),
      password: Rails.application.credentials.dig(:admin, :password) || ENV.fetch("ADMIN_PASSWORD", "password")
    )

    layout "admin"
  end
end
