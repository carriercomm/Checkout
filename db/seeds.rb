# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

BusinessDay.where(:index => 0, :name => 'Sunday'   ).first_or_create
BusinessDay.where(:index => 1, :name => 'Monday'   ).first_or_create
BusinessDay.where(:index => 2, :name => 'Tuesday'  ).first_or_create
BusinessDay.where(:index => 3, :name => 'Wednesday').first_or_create
BusinessDay.where(:index => 4, :name => 'Thursday' ).first_or_create
BusinessDay.where(:index => 5, :name => 'Friday'   ).first_or_create
BusinessDay.where(:index => 6, :name => 'Saturday' ).first_or_create

admin    = Role.where(:name => 'admin').first_or_create
approver = Role.where(:name => 'approver').first_or_create
Role.where(:name => 'attendant').first_or_create

# these users skip validations because they have invalid email
# addresses. We don't want to inadvertantly send email out into the
# world.

User.unscoped.where(username: 'system').first_or_initialize do |u|
  u.username = 'system'
  u.email    = 'system@localhost'
  u.password = Devise.friendly_token.first(8)
  u.disabled = true
  u.add_role :approver
  u.save!(:validate => false)
end

User.where(username: 'admin').first_or_initialize do |u|
  u.email    = 'admin@localhost'
  u.password = 'password'
  u.add_role :admin
  u.save!(:validate => false)
end
