ActionDispatch::Callbacks.to_prepare do
  Settings.defaults[:default_checkout_duration] = 2
end
