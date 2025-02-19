# This cancels a payment within Stripe, and makes a record
# within our database.
module Donations
  class Subscription
    class UpdateAmount
      include Mandate

      initialize_with :subscription, :amount_in_cents

      def call
        stripe_data = Stripe::Subscription.retrieve(subscription.stripe_id)

        Stripe::Subscription.update(
          subscription.stripe_id,
          items: [{
            id: stripe_data.items.data[0].id,
            price_data: {
              unit_amount: amount_in_cents,
              currency: 'usd',
              product: Exercism.secrets.stripe_recurring_product_id,
              recurring: {
                interval: 'month'
              }
            }
          }],
          proration_behavior: 'none'
        )

        subscription.update!(amount_in_cents:)

        # Update based on whether there is another different active subscription
        user = subscription.user
        user.update!(active_donation_subscription: user.donation_subscriptions.active.exists?)
      end
    end
  end
end
