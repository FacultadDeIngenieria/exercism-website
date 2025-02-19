require "application_system_test_case"
require_relative "../../../../support/capybara_helpers"

module Flows
  module Student
    module Exercise
      class ViewsExerciseMentoringTest < ApplicationSystemTestCase
        include CapybaraHelpers

        test "no mentoring" do
          user = create :user
          track = create :track
          create :user_track, user: user, track: track
          exercise = create :concept_exercise, track: track
          solution = create :concept_solution, exercise: exercise, user: user
          submission = create :submission, tests_status: :queued, solution: solution
          create :iteration, solution: solution, submission: submission
          create :submission_file, submission: submission

          use_capybara_host do
            sign_in!(user)
            visit track_exercise_mentor_discussions_path(track, exercise)

            assert_text "You have no past mentoring discussions"
            click_on "Request mentoring"
            assert_text "Submit mentoring request"
          end
        end

        test "requested mentoring" do
          user = create :user
          track = create :track
          create :user_track, user: user, track: track
          exercise = create :concept_exercise, track: track
          solution = create :concept_solution, exercise: exercise, user: user
          submission = create :submission, tests_status: :queued, solution: solution
          create :iteration, solution: solution, submission: submission
          create :submission_file, submission: submission

          create :mentor_request, solution: solution, student: user

          use_capybara_host do
            sign_in!(user)
            visit track_exercise_mentor_discussions_path(track, exercise)

            assert_text "You’ve requested mentoring"
            assert_text "Waiting on a mentor..."
          end
        end

        test "in progress mentoring discussion" do
          user = create :user
          mentor = create :user, handle: 'juanita'
          track = create :track
          create :user_track, user: user, track: track
          exercise = create :concept_exercise, track: track
          solution = create :concept_solution, exercise: exercise, user: user
          submission = create :submission, tests_status: :queued, solution: solution
          create :iteration, solution: solution, submission: submission
          create :submission_file, submission: submission

          create :mentor_discussion, :awaiting_student, solution: solution, student: user, mentor: mentor

          use_capybara_host do
            sign_in!(user)
            visit track_exercise_mentor_discussions_path(track, exercise)

            within(".mentoring-in-progress") { assert_text "juanita" }
          end
        end

        test "past mentoring discussions" do
          user = create :user
          mentor_1 = create :user, handle: 'juanita'
          mentor_2 = create :user, handle: 'aziz'
          mentor_3 = create :user, handle: 'yamikani'
          track = create :track
          create :user_track, user: user, track: track
          exercise = create :concept_exercise, track: track
          solution = create :concept_solution, exercise: exercise, user: user
          submission = create :submission, tests_status: :queued, solution: solution
          create :iteration, solution: solution, submission: submission
          create :submission_file, submission: submission

          create :mentor_discussion, :student_finished, solution: solution, student: user, mentor: mentor_1
          create :mentor_discussion, :student_finished, solution: solution, student: user, mentor: mentor_2

          use_capybara_host do
            sign_in!(user)
            visit track_exercise_mentor_discussions_path(track, exercise)

            within(".previous-discussions") do
              assert_text "juanita"
              assert_text "aziz"
              refute_text "yamikani"
            end

            # Create discussion finished by mentor
            discussion = create :mentor_discussion, :mentor_finished, solution: solution, student: user, mentor: mentor_3
            solution.mentoring_in_progress!

            # Reload page
            visit track_exercise_mentor_discussions_path(track, exercise)

            within(".previous-discussions") do
              assert_text "juanita"
              assert_text "aziz"
              refute_text "yamikani"
            end

            within(".mentoring-in-progress") { assert_text "yamikani" }

            discussion.finished!

            # Reload page
            visit track_exercise_mentor_discussions_path(track, exercise)

            within(".previous-discussions") do
              assert_text "juanita"
              assert_text "aziz"
              assert_text "yamikani"
            end
          end
        end
      end
    end
  end
end
