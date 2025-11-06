require 'rails_helper'
require_relative '../../../app/domain/entities/invoice'

RSpec.describe Domain::Entities::Invoice, type: :model do
  describe 'validations' do
    context 'with valid attributes' do
      it 'creates a invoice successfully' do
          invoice = Domain::Entities::Invoice.new(
              client_id: 1,
              amount: 10000,
              state: 1,
              due_date: "2025-11-06T14:34:15Z"
          )
        expect(invoice.client_id).to eq(1)
        expect(invoice.amount).to eq(10000)
        expect(invoice.state).to eq(1)
        expect(invoice.due_date).to eq("2025-11-06T14:34:15Z")
      end
    end
  end
end