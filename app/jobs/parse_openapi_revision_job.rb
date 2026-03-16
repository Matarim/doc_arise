# frozen_string_literal: true

class ParseOpenapiRevisionJob < ApplicationJob
  queue_as :default

  def perform(revision_id)
    revision = ApiRevision.find(revision_id)
    return unless revision.content.present?

    data = revision.content

    revision.endpoints.destroy_all
    revision.schemas.destroy_all
    revision.security_schemes.destroy_all

    (data['paths'] || {}).each do |path, methods|
      methods.each do |method_name, operation|
        next unless operation.is_a?(Hash)

        endpoint = revision.endpoints.create!(
          path:         path,
          method:       method_name.downcase,
          operation_id: operation['operationId'],
          summary:      operation['summary'],
          description:  operation['description'],
          deprecated:   operation['deprecated'] || false,
          security:     operation['security']
        )

        (operation['parameters'] || []).each do |param|
          endpoint.parameters.create!(
            name:        param['name'],
            in_location: param['in'],
            required:    param['required'] || false,
            description: param['description'],
            schema:      param['schema']
          )
        end

        (operation['responses'] || {}).each do |status_code, response|
          endpoint.responses.create!(
            status_code: status_code,
            description: response['description'],
            content:     response['content']
          )
        end
      end
    end

    (data.dig('components', 'schemas') || {}).each do |name, schema|
      revision.schemas.create!(
        name:        name,
        description: schema['description'],
        schema:      schema
      )
    end

    (data.dig('components', 'securitySchemes') || {}).each do |name, scheme|
      revision.security_schemes.create!(
        name:        name,
        description: scheme['description'],
        scheme:      scheme
      )
    end

    revision.update_columns(parsed_at: Time.current)
  end
end
