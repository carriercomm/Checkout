class KitDecorator < Draper::Base
  decorates :kit

  def as_json(options={})
    q     = options.delete(:q)
    raise self.inspect if q.nil?
    regexp = Regexp.quote(q)
    at    = asset_tags.select {|at| /#{regexp}/ =~ at }
    label = "[#{ at.join(", ") }] #{ branded_components_description }".squish

    {
      :label => label,
      :value => h.url_for(model)
    }
  end

  # Accessing Helpers
  #   You can access any helper via a proxy
  #
  #   Normal Usage: helpers.number_to_currency(2)
  #   Abbreviated : h.number_to_currency(2)
  #
  #   Or, optionally enable "lazy helpers" by including this module:
  #     include Draper::LazyHelpers
  #   Then use the helpers with no proxy:
  #     number_to_currency(2)

  # Defining an Interface
  #   Control access to the wrapped subject's methods using one of the following:
  #
  #   To allow only the listed methods (whitelist):
  #     allows :method1, :method2
  #
  #   To allow everything except the listed methods (blacklist):
  #     denies :method1, :method2

  # Presentation Methods
  #   Define your own instance methods, even overriding accessors
  #   generated by ActiveRecord:
  #
  #   def created_at
  #     h.content_tag :span, attributes["created_at"].strftime("%a %m/%d/%y"),
  #                   :class => 'timestamp'
  #   end
end
