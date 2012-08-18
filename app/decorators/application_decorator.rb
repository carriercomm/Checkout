class ApplicationDecorator < Draper::Base

  def localize_unless_nil(*args)
    #Avoid I18n::ArgumentError for nil values
    (args.first.nil?) ? "&nbsp;".html_safe : I18n.localize(*args)
  end

  def to_yes_no(val)
    val ? h.t('yes') : h.t('no')
  end

  def val_or_space(val)
    return val || "&nbsp;".html_safe
  end

end
