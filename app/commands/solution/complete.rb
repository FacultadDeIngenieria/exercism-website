class Solution
  class Complete
    include Mandate

    initialize_with :solution, :user_track

    def call
      raise SolutionHasNoIterationsError if solution.iterations.empty?

      solution.with_lock do
        return if solution.completed?

        solution.update!(completed_at: Time.current)
      end

      %i[anybody_there all_your_base whatever lackadaisical].each do |badge|
        AwardBadgeJob.perform_later(user, badge, context: exercise)
      end

      AwardBadgeJob.perform_later(user, :conceptual, context: exercise)
      AwardBadgeJob.perform_later(user, :completer)

      record_activity!
      log_metric!
    end

    private
    def record_activity!
      User::Activity::Create.(
        :completed_exercise,
        user,
        track: exercise.track,
        solution:
      )
    rescue StandardError => e
      Rails.logger.error "Failed to create activity"
      Rails.logger.error e.message
    end

    def log_metric!
      Metric::Queue.(:complete_solution, solution.completed_at, solution:, track:, user:)
    end

    memoize
    def user = solution.user

    memoize
    def exercise = solution.exercise

    memoize
    def track = solution.track
  end
end
