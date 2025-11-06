require 'httparty'

module Infrastructure
  module Http
    class ClientService
      include HTTParty
      base_uri ENV.fetch('URL_CLIENT_SERVICE', 'http://192.168.1.22:3000')

      def find_client(client_id)
        Rails.logger.info("Client Service URL: #{self.class.base_uri}")
        response = self.class.get("/api/v1/clients/#{client_id}")
        if response.success?
          Rails.logger.info("Cliente encontrado: #{response.body}")
          response.parsed_response
        else
          Rails.logger.error("Error al encontrar cliente: #{response.code} - #{response.body}")
          nil
        end
      rescue HTTParty::Error, StandardError => e
        Rails.logger.error("Excepción al comunicar con servicio de cliente: #{e.message}")
        nil
      end
    end
  end
end