module Admin
  class BaseController < ApplicationController
    include Pagy::Method

    http_basic_authenticate_with(
      name: Rails.application.credentials.admin_username,
      password: Rails.application.credentials.admin_password
    )

    layout "admin"
  end
end
