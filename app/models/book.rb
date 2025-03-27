class Book < ApplicationRecord
  belongs_to :author

  validates :title, presence: true
  validates :publication_date, presence: true
  validate :publication_date_cannot_be_in_the_future

  validates :rating, inclusion: { in: 0..5, message: "must be between 0 and 5" }, allow_nil: true

  STATUSES = %w[available checked_out reserved].freeze
  validates :status, inclusion: { in: STATUSES, message: "is not a valid status" }

  private

  def publication_date_cannot_be_in_the_future
    if publication_date.present? && publication_date > Date.today
      errors.add(:publication_date, "must be in the past or today")
    end
  end
end
