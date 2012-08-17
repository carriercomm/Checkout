class ApplicationDecorator < Draper::Base

  def localize_unless_nil(*args)
    #Avoid I18n::ArgumentError for nil values
    (args.first.nil?) ? h.raw("&nbsp;") : I18n.localize(*args)
  end

  def to_yes_no(val)
    val ? h.t('yes') : h.t('no')
  end

end
