require 'httparty'

module Infrastructure
  module Http
    class AuditService
      include HTTParty
      base_uri ENV.fetch('URL_AUDIT_SERVICE', 'http://192.168.1.22:3001')
      def create_audit(audit_data)
        Rails.logger.info("Audit Service URL: #{self.class.base_uri}")
        response = self.class.post('/api/v1/audits', body: audit_data.to_json, headers: { 'Content-Type' => 'application/json' })
        if response.success?
          Rails.logger.info("Audit created successfully: #{response.body}")
          response.parsed_response
        else
          Rails.logger.error("Error creating audit: #{response.code} - #{response.body}")
          { errors: ["Failed to create audit: #{response.body}"] }
        end
      rescue HTTParty::Error, StandardError => e
        Rails.logger.error("Exception when communicating with Audit Service: #{e.message}")
        { errors: ["Exception occurred: #{e.message}"] }
      end
    end
  end
end