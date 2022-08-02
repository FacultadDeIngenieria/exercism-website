class SyncTrackJob < ApplicationJob
  queue_as :default

  def perform(track, force_sync: false)
    Rails.logger.info "SYNC TRACK"
    Git::SyncTrack.(track, force_sync:)
  end
end
