module Git
  class SyncExerciseAuthors < Sync
    include Mandate

    def initialize(exercise)
      super(exercise.track, exercise.synced_to_git_sha)
      @exercise = exercise
    end

    def call
      ActiveRecord::Base.transaction do
        authors = ::User.where(github_username: authors_config)
        authors.find_each { |author| ::Exercise::Authorship::Create.(exercise, author) }

        # This is required to remove authors that were already added
        exercise.reload.update!(authors:)
      end
    end

    private
    attr_reader :exercise

    memoize
    def authors_config
      head_git_exercise.authors.to_a
    end

    memoize
    def head_git_exercise
      exercise_config = head_git_track.find_exercise(exercise.uuid)
      Git::Exercise.new(exercise_config[:slug], exercise.git_type, git_repo.head_sha, repo: git_repo)
    end
  end
end
