# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Location.all.each do |l|
  IceCube::TimeUtil::DAYS.each do |k,v|
    bh = BusinessHour.where(:location_id => l.id, :day => k, :day_index => v).first_or_initialize
    bh.save if bh.new_record?
  end
end
