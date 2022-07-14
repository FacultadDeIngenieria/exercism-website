class Metric::Queue
  include Mandate

  initialize_with :type, :occurred_at, :country_code, :attributes

  def call
    LogMetricJob.perform_later(type, occurred_at, country_code, **attributes)
  rescue StandardError => e
    # Don't crash if the creation fails, e.g. if sidekiq is down
    Bugsnag.notify(e)
  end
end
