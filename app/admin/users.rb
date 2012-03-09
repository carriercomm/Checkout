ActiveAdmin.register User do

  index do
    column :username
    column :email
    column :failed_attempts
    column :locked_at    
    column :suspended_until
    column :suspension_count
    column :disabled
  end

end
