module Git
  class SyncConceptAuthors < Sync
    include Mandate

    def initialize(concept)
      super(concept.track, concept.synced_to_git_sha)
      @concept = concept
    end

    def call
      ActiveRecord::Base.transaction do
        authors = ::User.where(github_username: authors_config)
        authors.find_each { |author| ::Concept::Authorship::Create.(concept, author) }

        # This is required to remove authors that were already added
        concept.reload.update!(authors:)
      end
    end

    private
    attr_reader :concept

    memoize
    def authors_config
      head_git_concept.authors.to_a
    end

    memoize
    def head_git_concept
      concept_config = head_git_track.find_concept(concept.uuid)
      Git::Concept.new(concept_config[:slug], git_repo.head_sha, repo: git_repo)
    end
  end
end
