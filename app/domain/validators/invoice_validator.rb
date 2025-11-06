module Domain
  module Validators
    class InvoiceValidator
      attr_reader :errors

      def initialize(invoice)
        @invoice = invoice
        @errors = []
      end

      def valid?
        validate_invoice_id
        validate_amount
        validate_due_date

        @errors.empty?
      end

      private

      def validate_invoice_id
        if @invoice.client_id.nil?
          @errors << "El client_id es obligatorio"
        end
      end

      def validate_amount
        if @invoice.amount.nil?
          @errors << "El amount es obligatorio"
        elsif @invoice.amount <= 0
          @errors << "El amount debe ser mayor que 0"
        end
      end

      def validate_due_date
        if @invoice.due_date.nil?
          @errors << "La fecha de emisión (due_date) es obligatoria"
        else
          raw = @invoice.due_date
          begin
            parsed = if raw.is_a?(String)
                       # Accept ISO8601 strings like "2025-11-06T14:34:15Z"
                       Time.iso8601(raw)
                     elsif raw.is_a?(Time) || raw.is_a?(DateTime)
                       raw.to_time
                     else
                       # unsupported type
                       raise ArgumentError, "invalid due_date type"
                     end
            # If you want to enforce additional rules (e.g. not in the past),
            # add them here using `parsed` (which is a Time instance).
          rescue ArgumentError, TypeError
            @errors << "El due_date debe tener este formato similar 2025-11-06T14:34:15Z"
          end
        end
      end
    end
  end
end