class Quote < ApplicationRecord
  belongs_to :company

  validates :name, presence: true

  scope :ordered, -> { order(id: :desc) }

  # after_create_commit -> { broadcast_prepend_to "quotes", partial: "quotes/quote", locals: { quote: self }, target: "quotes" }
  # those are synchronous 👇
  # after_create_commit -> { broadcast_prepend_to "quotes" }
  # after_update_commit -> { broadcast_replace_to "quotes" }
  # after_destroy_commit -> { broadcast_remove_to "quotes" }

  # these are asynchronous using background jobs.
  # after_create_commit -> { broadcast_prepend_later_to "quotes" }
  # after_update_commit -> { broadcast_replace_later_to "quotes" }
  # after_destroy_commit -> { broadcast_remove_later_to "quotes" }
  # syntactic sugar 👇
  # broadcasts_to ->(quote) { "quotes" }, inserts_by: :prepend # 🔥 it broadcasts to all users...
 
  # The rules for secure broadcastings are the following:

  # Users who share broadcastings should have the lambda return an array with the same values.
  # Users who shouldn't share broadcastings should have the lambda return an array with different values.
  broadcasts_to ->(quote) { [quote.company, "quotes"] }, inserts_by: :prepend

end
