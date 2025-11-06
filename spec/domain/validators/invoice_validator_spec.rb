require 'rails_helper'
require_relative '../../../app/domain/validators/invoice_validator'

RSpec.describe Domain::Validators::InvoiceValidator do
  describe '#validate' do
    context 'with valid attributes' do
      it 'returns true' do
        invoice = Domain::Entities::Invoice.new(
          client_id: 1,
          amount: 10000,
          state: 1,
          due_date: "2025-11-06T14:34:15Z"
        )
        validator = Domain::Validators::InvoiceValidator.new(invoice)
        expect(validator.valid?).to be_truthy
      end
    end

    context 'with invalid attributes' do
      it 'returns false' do
        invoice = Domain::Entities::Invoice.new(
          client_id: nil,
          amount: -10000,
          state: 2,
          due_date: "2025-11-06T14:34:15Z"
        )
        validator = Domain::Validators::InvoiceValidator.new(invoice)
        expect(validator.valid?).to be_falsey
        expect(validator.errors.size).to eq(2)
        puts validator.errors
        expect(validator.errors).to include("El client_id es obligatorio")
        expect(validator.errors).to include("El amount debe ser mayor que 0")
      end
    end
  end
end