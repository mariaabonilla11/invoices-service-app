module Domain
  module Repositories
    class InvoiceRepository
      def create(invoice)
        raise NotImplementedError
      end

      def find_by_id(id)
        raise NotImplementedError
      end
    end
  end
end