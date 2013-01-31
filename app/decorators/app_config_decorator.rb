class AppConfigDecorator < ApplicationDecorator
  decorates :app_config

  def default_checkout_length
    coalesce(source.default_checkout_length, "<span class='help-block'>None specified</span>", "days")
  end

end
