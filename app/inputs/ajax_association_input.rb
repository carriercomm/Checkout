class AjaxAssociationInput < SimpleForm::Inputs::StringInput

  def input
    input_html_classes.push 'select2-json-autocomplete'
    input_html_classes.push 'select-user'

    path = options.delete(:path)
    raise "Missing :path parameter, which should point to an ajax url returning Select2 formatted JSON" if path.nil?

    attr = object.send(attribute_name)
    raise "The association object type doesn't have a to_s method" unless attr.respond_to?(:to_s)

    opts = {
      :hidden => true,
      "data-ajax-url" => path,
      "data-text" => attr.to_s
    }

    attr_id = (attribute_name.to_s + "_id").to_sym

    @builder.text_field(attr_id, input_html_options.merge(opts))
  end

end
