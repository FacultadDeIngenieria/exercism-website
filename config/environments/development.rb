require "active_support/core_ext/integer/time"

Rails.application.configure do

  # Specify AnyCable WebSocket server URL to use by JS client
  config.after_initialize do
    if AnyCable::Rails.enabled?
      config.action_cable.url = ActionCable.server.config.url = ENV.fetch("CABLE_URL", "ws://facultaddeingenieria.duckdns.org:3334/cable")
    end
  end

  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc.
  ENV['EXERCISM_DOCKER'] ? config.file_watcher = ActiveSupport::FileUpdateChecker : config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # TODO: Change to exercism on launch
  config.session_store :cookie_store, key: "_exercism", domain: "facultaddeingenieria.duckdns.org"

  config.hosts << "facultaddeingenieria.duckdns.org"
  #config.hosts << "website" if ENV['EXERCISM_DOCKER']
  #config.hosts << /.*.ngrok.io/
end

Rails.application.routes.default_url_options = {
  host: "http://facultaddeingenieria.duckdns.org:3020"
}
