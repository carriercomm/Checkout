# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

BusinessDay.create!(:index => 0, :name => 'Sunday')
BusinessDay.create!(:index => 1, :name => 'Monday')
BusinessDay.create!(:index => 2, :name => 'Tuesday')
BusinessDay.create!(:index => 3, :name => 'Wednesday')
BusinessDay.create!(:index => 4, :name => 'Thursday')
BusinessDay.create!(:index => 5, :name => 'Friday')
BusinessDay.create!(:index => 6, :name => 'Saturday')

Role.create!(:name => 'admin')
Role.create!(:name => 'attendant')

# these users skip validations because they have invalid email
# addresses. We don't want to inadvertantly send email out into the
# world.

u = User.new
u.username = 'system'
u.email    = 'system@localhost'
u.password = Devise.friendly_token.first(8)
u.disabled = true
u.save!(:validate => false)

u = User.new
u.username = 'admin'
u.email    = 'admin@localhost'
u.password = 'password'
u.save!(:validate => false)
u.add_role "admin"

# there has to be a default checkout length otherwise it will break reservations
AppConfig.instance.update_attributes(default_checkout_length: 2)
