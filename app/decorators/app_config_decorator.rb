class AppConfigDecorator < ApplicationDecorator
  decorates :app_config

  def default_checkout_length
    coalesce(model.default_checkout_length, "<span class='help-block'>None specified</span>", "days")
  end

end
