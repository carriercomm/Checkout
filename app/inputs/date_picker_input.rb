class DatePickerInput < SimpleForm::Inputs::StringInput

  def input
    value = object.send(attribute_name)

    if value
      value = I18n.localize(value, :format => "%Y/%m/%d")
      input_html_options.merge!(value: value)
    end

    @builder.text_field(attribute_name, input_html_options)
  end

end
