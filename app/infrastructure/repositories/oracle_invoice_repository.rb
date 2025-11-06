require_dependency Rails.root.join('app/domain/repositories/invoice_repository').to_s
require_dependency Rails.root.join('app/domain/entities/invoice').to_s
module Infrastructure
  module Repositories
    class OracleInvoiceRepository < Domain::Repositories::InvoiceRepository
      def create(invoice)
        result = ::Invoice.create(client_id: invoice.client_id, amount: invoice.amount, due_date: invoice.due_date)
        return result if result.persisted?
        { errors: result.errors.full_messages }
      end

      def find_by_id(id)
        # Implementación específica para Oracle
        record = ::Invoice.find_by(id: id)
        return nil unless record

        Domain::Entities::Invoice.new(
          id: record.id,
          client_id: record.client_id,
          amount: record.amount,
          state: record.state,
          due_date: record.due_date,
          created_at: record.created_at,
          updated_at: record.updated_at
        )
      end

      def filter(filters)
        start_date = filters[:start_date]
        end_date = filters[:end_date]

        # Implementación específica para Oracle
        query = ::Invoice.where(nil)
        query = query.where("due_date >= ?", start_date) if start_date
        query = query.where("due_date <= ?", end_date) if end_date

        query.map do |record|
          Domain::Entities::Invoice.new(
            id: record.id,
            client_id: record.client_id,
            amount: record.amount,
            state: record.state,
            due_date: record.due_date,
            created_at: record.created_at,
            updated_at: record.updated_at
          )
        end
      end
    end
  end
end