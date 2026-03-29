# frozen_string_literal: true

class ParseOpenapiRevisionJob < ApplicationJob
  queue_as :default

  def perform(api_revision_id)
    revision = ApiRevision.find(api_revision_id)
    return unless revision.content.present?

    Rails.logger.info "🔄 Starting parse for revision ##{revision.revision_number} (ID: #{revision.id})"

    openapi = revision.content.is_a?(String) ? JSON.parse(revision.content) : revision.content
    openapi = openapi.deep_symbolize_keys

    # Clean old data
    revision.endpoints.destroy_all
    revision.schemas.destroy_all
    revision.security_schemes.destroy_all

    # === PATHS → ENDPOINTS ===
    (openapi[:paths] || {}).each do |path, operations|
      operations.each do |method, op|
        endpoint = Endpoint.create!(
          api_revision_id: revision.id,
          path:            path.to_s,
          method:          method.to_s.upcase,
          summary:         op[:summary],
          description:     op[:description],
          operation_id:    op[:operationId],
          deprecated:      op[:deprecated] || false,
          request_body:    op[:requestBody] || {},
          security:        op[:security] || [],
          version:         revision.version
        )

        # Parameters
        (op[:parameters] || []).each do |p|
          endpoint.parameters.create!(
            name:        p[:name],
            in_location: p[:in],
            required:    p[:required] || false,
            schema:      p[:schema] || {},
            description: p[:description],
            example:     p[:example]
          )
        end

        # Responses
        (op[:responses] || {}).each do |status, resp|
          endpoint.responses.create!(
            status_code: status.to_s,
            description: resp[:description],
            content:     resp[:content] || {}
          )
        end
      end
    end

    # === COMPONENTS ===
    if openapi.dig(:components, :securitySchemes)
      openapi[:components][:securitySchemes].each do |name, scheme|
        revision.security_schemes.create!(
          name: name.to_s,
          scheme: scheme,
          description: scheme[:description]
        )
      end
    end

    Rails.logger.info "✅ Parse complete! #{revision.endpoints.count} endpoints created for revision ##{revision.revision_number}"
  rescue => e
    Rails.logger.error "❌ Parse failed for revision #{api_revision_id}: #{e.message}"
    raise
  end
end
