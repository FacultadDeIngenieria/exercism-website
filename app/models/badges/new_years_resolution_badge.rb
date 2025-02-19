module Badges
  class NewYearsResolutionBadge < Badge
    seed "New Year's resolution",
      :rare,
      'new-years-resolution',
      'Submitted a solution on January 1st'

    def self.worth_queuing?(solution:)
      solution.created_at.yday == 1
    end

    def award_to?(user)
      user.solutions.
        where('DAYOFYEAR(solutions.created_at) = 1').
        exists?
    end

    def send_email_on_acquisition?
      true
    end
  end
end
