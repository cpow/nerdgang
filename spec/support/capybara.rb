require "capybara/rspec"

# Use rack_test driver for speed (no JavaScript)
Capybara.default_driver = :rack_test

# Configure for feature specs
RSpec.configure do |config|
  config.include Capybara::DSL, type: :feature

  # HTTP Basic Auth helper for feature specs
  config.include Module.new {
    def login_as_admin
      page.driver.browser.authorize("admin", "password")
    end
  }, type: :feature
end
