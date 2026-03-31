require "rails_helper"

RSpec.describe BotBlocker do
  let(:app) { ->(env) { [200, {}, ["OK"]] } }
  let(:middleware) { described_class.new(app) }

  def env_for(path)
    Rack::MockRequest.env_for(path)
  end

  describe "blocked paths" do
    %w[
      /wp-admin/setup-config.php
      /wordpress/wp-admin/setup-config.php
      /wp-login.php
      /wp-content/uploads/shell.php
      /wp-includes/js/jquery.php
      /xmlrpc.php
      /wp-cron.php
      /.env
      /phpmyadmin
      /administrator/index.php
      /admin.php
      /config.php
      /some/random/path.php
    ].each do |path|
      it "blocks #{path}" do
        status, _, body = middleware.call(env_for(path))

        expect(status).to eq(403)
        expect(body).to eq(["Forbidden"])
      end
    end
  end

  describe "allowed paths" do
    %w[
      /
      /newsletters
      /admin
      /admin/newsletters
      /subscribers
      /unsubscribe/some-token
      /webhooks/resend
    ].each do |path|
      it "allows #{path}" do
        status, _, body = middleware.call(env_for(path))

        expect(status).to eq(200)
        expect(body).to eq(["OK"])
      end
    end
  end
end
