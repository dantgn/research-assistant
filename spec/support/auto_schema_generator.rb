# frozen_string_literal: true

module AutoSchemaGenerator
  def self.included(base)
    base.after(:each) do |example|
      AutoSchemaGenerator.generate_schema_for_response(example, response)
    end
  end

  def self.generate_schema_for_response(example, response)
    # Only process rswag request specs with responses
    return unless example.metadata[:operation].present? &&
                  defined?(response) && response.present? &&
                  response.body.present?

    begin
      data = JSON.parse(response.body)

      # Generate schema
      schema = generate_openapi_schema(data)

      # Update example metadata
      example.metadata[:response][:content] = {
        'application/json' => {
          schema: schema,
          examples: {
            success: {
              summary: 'Successful response',
              value: data
            }
          }
        }
      }
    rescue JSON::ParserError => e
      puts "⚠ Could not parse JSON response for schema generation: #{e.message}"
    rescue => e
      puts "⚠ Error generating schema: #{e.message}"
    end
  end

  def self.generate_openapi_schema(data)
    case data
    when Hash
      properties = {}

      data.each do |key, value|
        properties[key] = generate_openapi_schema(value)
      end

      schema = { type: 'object', properties: properties }
      schema
    when Array
      if data.empty?
        { type: 'array', items: { type: 'object' } }
      else
        { type: 'array', items: generate_openapi_schema(data.first) }
      end
    when String
      if data.match?(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)
        { type: 'string', format: 'date-time' }
      elsif data.match?(/\A\d{4}-\d{2}-\d{2}\z/)
        { type: 'string', format: 'date' }
      elsif data.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
        { type: 'string', format: 'uuid' }
      else
        { type: 'string' }
      end
    when Integer
      { type: 'integer' }
    when Float, BigDecimal
      { type: 'number', format: 'float' }
    when TrueClass, FalseClass
      { type: 'boolean' }
    when NilClass
      { type: 'string', nullable: true }
    else
      { type: 'string' }
    end
  end
end
