class NewsletterMailer < ApplicationMailer
  def weekly_digest(subscriber, newsletter)
    @subscriber = subscriber
    @newsletter = newsletter
    @unsubscribe_url = unsubscribe_url(token: @subscriber.unsubscribe_token)

    mail(
      to: @subscriber.email,
      subject: @newsletter.title
    )
  end

  def welcome(subscriber)
    @subscriber = subscriber
    @unsubscribe_url = unsubscribe_url(token: @subscriber.unsubscribe_token)

    mail(
      to: @subscriber.email,
      subject: "Welcome to NerdGang — you've made a mass-produced decision"
    )
  end
end
