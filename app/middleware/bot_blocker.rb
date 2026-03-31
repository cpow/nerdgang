class BotBlocker
  BLOCKED_PATHS = %w[
    /wp-admin
    /wp-login
    /wp-content
    /wp-includes
    /wordpress
    /xmlrpc.php
    /wp-cron.php
    /wp-config
    /.env
    /phpmyadmin
    /administrator
    /admin.php
    /config.php
    /setup-config.php
  ].freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    path = env["PATH_INFO"].to_s.downcase

    if blocked?(path)
      [403, {"content-type" => "text/plain"}, ["Forbidden"]]
    else
      @app.call(env)
    end
  end

  private

  def blocked?(path)
    BLOCKED_PATHS.any? { |prefix| path.include?(prefix) } ||
      path.end_with?(".php")
  end
end
