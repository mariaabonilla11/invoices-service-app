
require_dependency Rails.root.join('app/infrastructure/http/audit_service').to_s
module UseCases
  module Invoices
    class FindInvoice
      def initialize(invoice_repository:)
        @invoice_repository = invoice_repository
        @audit_client = Infrastructure::Http::AuditService.new
      end

      def execute(id)
        # 1. Buscar la factura
        invoice = @invoice_repository.find_by_id(id)

        # 2. Validar si existe
        unless invoice
          return build_error_response(["invoice con ID #{id} no encontrado"])
        end

        # 3. Registrar auditoría de consulta
        register_audit_event(invoice)

        # 4. Retornar resultado
        build_success_response(invoice)
      end

      private

      def register_audit_event(invoice)
        @audit_client.create_audit(
          entity: 'invoice',
          action: 'read',
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

      def build_success_response(client)
        {
          success: true,
          data: client,
          errors: []
        }
      end

      def build_error_response(errors)
        {
          success: false,
          data: nil,
          errors: errors
        }
      end
    end
  end
end