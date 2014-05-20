module MappingsHelper
  def mapping_options
    Mapping.by_company(session['company_id']).with_fields.map{|m| [m.title, m.id]}
  end

  def line_item_mapping_fields
    mapping_fields('line_item', 'line_item')
  end

  def document_mapping_fields
    mapping_fields('invoice',   'document')
  end

  def mapping_fields(model_name, data_model)
    properties = Sk.read_schema(model_name)['properties']
    properties = properties.select {|name, properties| !properties['readonly'] && !DISALLOWED_MAPPING_FIELDS.include?(name)}
    properties.map do |name, api_params|
      attributes = Hash[api_params.map { |k, v| ["data-#{k}", v] }]
      attributes.merge!('data-target' => name, 'data-model-to-import' => data_model)
      attributes
    end
  end

  DISALLOWED_MAPPING_FIELDS = %w(_destroy line_items items lock_version client_id).freeze
end
