ActionDispatch::Callbacks.to_prepare do
  Settings.defaults[:default_loan_duration] = 2
  Settings.defaults[:attendants_can_self_check_out] = false
  Settings.defaults[:clients_can_see_equipment_outside_their_groups] = false
end
