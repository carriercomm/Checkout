class ApplicationDecorator < Draper::Base

  def localize_unless_nil(*args)
    #Avoid I18n::ArgumentError for nil values
    (args.first.nil?) ? "&nbsp;".html_safe : I18n.localize(*args)
  end

  def to_yes_no(val)
    val ? h.t('boolean.yes') : h.t('boolean.no')
  end

  def val_or_space(val)
    ActiveSupport::Deprecation.warn "val_or_space() is deprecated, use coalesce() instead.", caller
    coalesce(val)
  end

  def coalesce(val, empty_val = "&nbsp;", suffix = "")
    response = String.new
    if val
      response = val.to_s + " " + suffix
    else
      response = empty_val
    end
    response.html_safe
  end

end
