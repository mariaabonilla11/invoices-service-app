require_dependency Rails.root.join('app/infrastructure/repositories/oracle_invoice_repository').to_s
require_dependency Rails.root.join('app/infrastructure/http/audit_service').to_s
module UseCases
  module Invoices
    class CreateInvoice
      def initialize(repository: Infrastructure::Repositories::OracleInvoiceRepository.new)
        @repository = repository
        @audit_client = Infrastructure::Http::AuditService.new
      end

      def execute(invoice)
        if invoice.due_date.is_a?(String)
          due = begin
            Time.zone.parse(invoice.due_date)
          rescue ArgumentError
            nil
          end
        else
          due = invoice.due_date
        end

        invoice = Domain::Entities::Invoice.new(
          client_id: invoice.client_id,
          amount: invoice.amount,
          due_date: due
        )
        result = @repository.create(invoice)

        unless result
          Rails.logger.error("Error creando factura: #{invoice.errors.full_messages.join(', ')}")
          return nil
        end

        #  Registrar auditoría de creación (pasar result que tiene el ID asignado)
        register_audit_event(result)
        return result
      end

      def register_audit_event(invoice)
        @audit_client.create_audit(
          entity: 'invoice',
          action: 'create',
          entity_id: invoice.id.to_s,
          metadata: {
            invoice_id: invoice.id,
            client_id: invoice.client_id,
            amount: invoice.amount,
            due_date: invoice.due_date&.iso8601
          }.to_json,
          timestamp: Time.now.utc.iso8601,
          service: 'invoices-service'
        )
      rescue => e
        Rails.logger.error("Error registrando auditoría: #{e.message}")
      end
    end
  end
end
