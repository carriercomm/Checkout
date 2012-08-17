class ApplicationDecorator < Draper::Base

  def localize_unless_nil(*args)
    #Avoid I18n::ArgumentError for nil values
    if args.first.nil?
      h.raw("&nbsp;")
    else
      I18n.localize(*args)
    end
  end

  def to_yes_no(val)
    val ? h.t('user.disabled.true') : h.t('user.disabled.false')
  end

end
