require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Journey
    class OverviewTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user sees track learning details" do
        user = create :user
        track = create :track
        user_track = create :user_track, user: user, track: track, created_at: Time.utc(2016, 12, 25)

        exercise = create :concept_exercise, track: track
        solution = create :concept_solution, exercise: exercise, user: user
        create :mentor_discussion, student: user, solution: solution, status: :finished

        exercise = create :concept_exercise, track: track
        solution = create :concept_solution, exercise: exercise, user: user
        create :mentor_discussion, student: user, solution: solution, status: :awaiting_student

        exercise = create :concept_exercise, track: track
        solution = create :concept_solution, exercise: exercise, user: user
        create :mentor_request, student: user, solution: solution, status: :pending

        use_capybara_host do
          sign_in!(user)
          visit journey_url

          assert_text "25 Dec 2016"
          assert_text "When you joined the Ruby Track"
          assert_text "You started working through the Ruby Track #{Time.current.year - user_track.created_at.year} years ago."
          assert_text "1\nMentoring session completed"
          assert_text "You have 1 discussion in progress and 1 solution in the queue."
        end
      end

      test "user sees zero state for track learning" do
        user = create :user
        track = create :track
        create :user_track, user: user, track: track

        use_capybara_host do
          sign_in!(user)
          visit journey_url

          assert_text "You have none in progress and none in the queue"
        end
      end

      test "user sees zero state for mentoring" do
        user = create :user
        track = create :track
        create :user_track, user: user, track: track

        use_capybara_host do
          sign_in!(user)
          visit journey_url

          assert_text "You haven't mentored anyone yet"
          assert_link "Try mentoring", href: mentoring_path
        end
      end

      test "user sees zero state for contributing" do
        user = create :user
        track = create :track
        create :user_track, user: user, track: track

        use_capybara_host do
          sign_in!(user)
          visit journey_url

          assert_text "You haven't contributed to Exercism yet"
          assert_link "See how you can contribute", href: contributing_root_path
        end
      end
    end
  end
end
