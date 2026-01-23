require "vcr"
require "webmock/rspec"

VCR.configure do |config|
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.allow_http_connections_when_no_cassette = false

  # Filter sensitive data if needed
  # config.filter_sensitive_data('<API_KEY>') { ENV['API_KEY'] }

  # Ignore localhost for system tests
  config.ignore_localhost = true

  # Default cassette options
  config.default_cassette_options = {
    record: :new_episodes,
    match_requests_on: [:method, :uri]
  }
end

# Allow WebMock stubbing outside of VCR cassettes for error testing
WebMock.enable!
WebMock.disable_net_connect!(allow_localhost: true)
