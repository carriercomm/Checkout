class AjaxAssociationInput < SimpleForm::Inputs::StringInput

  def input
    input_html_classes.push 'select2-json-autocomplete'

    # give this association type a unique class - for testing or javascript usage
    input_html_classes.push "select-#{object.class.to_s.underscore.dasherize}"

    path = options.delete(:path)
    raise "Missing :path parameter, which should point to an ajax url returning Select2 formatted JSON" if path.nil?

    # apply a decorator to this object so we get appropriate view
    # formatting of the value
    decorator_class  = (object.class.to_s + "Decorator").constantize
    decorated_object = decorator_class.decorate(object)

    # fetch the attribute value
    attr = decorated_object.send(attribute_name)


    # see if there's a to_select2_s formatter defined for this
    # attribute, this gives us the ability to customize the output
    data_text = if attr.respond_to?(:to_select2_s)
                  attr.to_select2_s
                elsif attr.respond_to?(:to_s)
                  attr.to_s
                else
                  raise "The association object type doesn't have a to_s method"
                end

    # marshal the needed data to render the select2 widget into data
    # attributes
    opts = {
      "data-ajax-url" => path,
      "data-text" => data_text
    }

    attr_id = (attribute_name.to_s + "_id").to_sym

    @builder.text_field(attr_id, input_html_options.merge(opts))
  end

end
