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

u = User.create!(:username => 'admin', :email => 'admin@example.com', :password => 'password', :password_confirmation => 'password')
u.add_role "admin"

