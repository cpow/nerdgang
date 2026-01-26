class Subscriber < ApplicationRecord
  include Discard::Model

  default_scope -> { kept }

  validates :email, presence: true,
    uniqueness: {case_sensitive: false},
    format: {with: URI::MailTo::EMAIL_REGEXP}
end
