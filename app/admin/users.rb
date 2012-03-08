ActiveAdmin.register User do

  index do
    column :username
    column :email
    column :failed_attempts
    column :locked_at    
    column "Is Suspended", :doghoused
    column "Suspended Until",:doghouse_expiry
    column "Suspended Count", :doghouse_count
    column :disabled
  end

end
