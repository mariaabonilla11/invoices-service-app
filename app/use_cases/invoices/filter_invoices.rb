require_dependency Rails.root.join('app/infrastructure/http/audit_service').to_s

module UseCases
  module Invoices
    class FilterInvoices
      def initialize(repository: Infrastructure::Repositories::OracleInvoiceRepository.new)
        @invoice_repository = repository
        @audit_client = Infrastructure::Http::AuditService.new
      end

      def execute(filters)
        # 1. Aplicar filtros
        if filters[:start_date].is_a?(String)
          start_date = begin
            Time.zone.parse(filters[:start_date])
          rescue ArgumentError
            nil
          end
        else
          start_date = filters[:start_date]
        end

        if filters[:end_date].is_a?(String)
          end_date = begin
            Time.zone.parse(filters[:end_date])
          rescue ArgumentError
            nil
          end
        else
          end_date = filters[:end_date]
        end

        invoices = @invoice_repository.filter(start_date: start_date, end_date: end_date)
        
        # 2. Validar si existen resultados
        if invoices.empty?
          return build_error_response(["No se encontraron facturas con los criterios especificados"])
        end

        # 3. Registrar auditoría de la operación de filtrado
        register_audit_event(filters, invoices.count)

        # 4. Retornar resultados
        build_success_response(invoices)
      end

      private

      def build_success_response(invoices)
        {
          success: true,
          data: invoices,
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

      def register_audit_event(filters, result_count)
        # Auditar la operación de filtrado (no una factura específica)
        @audit_client.create_audit(
          entity: 'invoice',
          action: 'filter',
          entity_id: 'bulk_filter', # No hay un ID específico, es una operación de consulta múltiple
          metadata: {
            filters: {
              start_date: filters[:start_date]&.iso8601,
              end_date: filters[:end_date]&.iso8601
            },
            result_count: result_count
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