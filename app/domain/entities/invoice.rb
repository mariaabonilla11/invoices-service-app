module Domain
  module Entities
    class Invoice
      attr_accessor :id, :client_id, :amount, :state, :due_date, :created_at, :updated_at

      def initialize(id: nil, client_id: nil, amount: nil, state: nil, due_date: nil, created_at: nil, updated_at: nil)
        @id = id
        @client_id = client_id
        @amount = amount
        @state = state
        @due_date = due_date
        @created_at = created_at
        @updated_at = updated_at
      end
    end
  end
end