class SendNewsletterJob < ApplicationJob
  queue_as :default

  def perform(newsletter_id)
    newsletter = Newsletter.find(newsletter_id)

    return unless newsletter.sendable?

    Subscriber.subscribed.find_each do |subscriber|
      NewsletterMailer.weekly_digest(subscriber, newsletter).deliver_later
    end

    newsletter.mark_as_sent!
  end
end
