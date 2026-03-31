module Admin
  class BaseController < ApplicationController
    include Pagy::Method

    rate_limit to: 60, within: 1.minute, by: -> { request.remote_ip }

    http_basic_authenticate_with(
      name: Rails.application.credentials.admin_username,
      password: Rails.application.credentials.admin_password
    )

    layout "admin"
  end
end
