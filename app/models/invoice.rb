class Invoice < ApplicationRecord
  validates :client_id, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :state, presence: true, inclusion: { in: %w[active inactive] }
  validates :due_date, presence: true

  enum state: {
    active: 1,
    inactive: 0,
    pending: 2,
    suspended: 3
  }
end
