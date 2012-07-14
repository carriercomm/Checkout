class LegacyEquipment < ActiveRecord::Base
  establish_connection :legacy
  set_table_name 'equipment'
  
  belongs_to :legacy_budget, :foreign_key => 'budget_id'
  belongs_to :legacy_category, :foreign_key => 'cat_id'
  belongs_to :legacy_location, :foreign_key => 'loc_id'

  def self.convert_special_to_boolean!
    connection.execute "UPDATE equipment SET special = 0 WHERE LCASE(special) = 'no' OR special IS NULL OR TRIM(special) = ''"
    connection.execute "UPDATE equipment SET special = 1 WHERE LCASE(special) = 'yes'"
  end

  def self.convert_checkoutable_to_boolean!
    connection.execute "UPDATE equipment SET checkoutable = 0 WHERE LCASE(checkoutable) = 'no' OR checkoutable IS NULL OR TRIM(checkoutable) = ''"
    connection.execute "UPDATE equipment SET checkoutable = 1 WHERE LCASE(checkoutable) = 'yes'"
  end

  def self.convert_insured_to_boolean!
    connection.execute "UPDATE equipment SET eq_insured = 0 WHERE LCASE(eq_insured) = 'off' OR eq_insured IS NULL OR TRIM(eq_insured) = ''"
    connection.execute "UPDATE equipment SET eq_insured = 1 WHERE LCASE(eq_insured) = 'on'"
  end

  def self.convert_eq_removed_to_boolean!
    connection.execute "UPDATE equipment SET eq_removed = 0 WHERE LCASE(eq_removed) = 'off' OR eq_removed IS NULL OR TRIM(eq_removed) = '' OR LCASE(eq_removed) = 'no'"
    connection.execute "UPDATE equipment SET eq_removed = 1 WHERE LCASE(eq_removed) = 'on'"
  end

  def self.dedupe_brands!
    connection.execute "UPDATE equipment SET eq_manufacturer='Adam Audio' WHERE eq_manufacturer='Adam'"
    connection.execute "UPDATE equipment SET eq_manufacturer='Apple' WHERE eq_manufacturer='APPLE COMPUTER' OR eq_manufacturer='APPLE COMPUTER CORP' OR eq_manufacturer='APPLE COMPUTER INC'"
    connection.execute "UPDATE equipment SET eq_manufacturer='Unknown' WHERE eq_manufacturer='Bad Tag' OR eq_manufacturer=''"
    connection.execute "UPDATE equipment SET eq_manufacturer='Bi-System' WHERE eq_manufacturer='Bi-Systems'"
    connection.execute "UPDATE equipment SET eq_manufacturer='Blackmagic Design' WHERE eq_manufacturer='BlackMagicDesign'"
    connection.execute "UPDATE equipment SET eq_manufacturer='Century Precision Optics' where eq_manufacturer LIKE '%century%'"
    connection.execute "UPDATE equipment SET eq_manufacturer='Circuit Specialists Inc' where eq_manufacturer LIKE '%circuit%'"
    connection.execute "UPDATE equipment SET eq_manufacturer='Dell' where eq_manufacturer = 'DELL COMPUTER CORP'"
    connection.execute "UPDATE equipment SET eq_manufacturer='DPA Microphones' WHERE eq_manufacturer LIKE '%dpa%'"
    connection.execute "UPDATE equipment SET eq_manufacturer='EarthLCD' WHERE eq_manufacturer='EARTH LCD' OR eq_manufacturer='EARTH-LCD'"
    connection.execute "UPDATE equipment SET eq_manufacturer='Earthworks Audio' where eq_manufacturer LIKE '%earthworks%'"
    connection.execute "UPDATE equipment SET eq_manufacturer='GW Instek' where eq_manufacturer='GWInstek'"
    connection.execute "UPDATE equipment SET eq_manufacturer='Hakko' where eq_manufacturer='Hako'"
    connection.execute "UPDATE equipment SET eq_manufacturer='Hewlett-Packard' where eq_manufacturer='HEWLETT PACKARD' OR eq_manufacturer='HP'"
    connection.execute "UPDATE equipment SET eq_manufacturer='Jet' where eq_manufacturer LIKE '%jet%'"
    connection.execute "UPDATE equipment SET eq_manufacturer='Kino Flo' where eq_manufacturer='Kinoflow'"
    connection.execute "UPDATE equipment SET eq_manufacturer='Lightspeed Design' where eq_manufacturer LIKE '%lightspeed%'"
    connection.execute "UPDATE equipment SET eq_manufacturer='Matthews' where eq_manufacturer = 'MATTHEWS HOLLYWOOD'"
    connection.execute "UPDATE equipment SET eq_manufacturer='Penguin Computing' WHERE eq_manufacturer LIKE '%penguin%'"
    connection.execute "UPDATE equipment SET eq_manufacturer='Point Grey Research' WHERE eq_manufacturer = 'PT. GREY RESEARCH'"
    connection.execute "UPDATE equipment SET eq_manufacturer='ProMAX' WHERE eq_manufacturer LIKE '%promax%'"
    connection.execute "UPDATE equipment SET eq_manufacturer='SensAble Technologies' WHERE eq_manufacturer LIKE '%sensable%'"
  end

  def self.dedupe_serial_numbers!
    sql_statement = <<-END_SQL
    update equipment
	inner join (select eq_serial_num
    	from equipment
        group by eq_serial_num
        having count(eq_serial_num) > 1) as duplicates ON equipment.eq_serial_num = duplicates.eq_serial_num
    set equipment.eq_serial_num = NULL    
    END_SQL

    connection.execute sql_statement
  end

end

class LegacyCategory < ActiveRecord::Base
  establish_connection :legacy
  set_table_name 'eq_categories'
  set_primary_key :cat_id
  has_many :legacy_equipments
end

class LegacyBudget < ActiveRecord::Base
  establish_connection :legacy
  set_table_name 'budgets'
  set_primary_key :budget_id
  has_many :legacy_equipments
end

class LegacyLocation <ActiveRecord::Base
  establish_connection :legacy
  set_table_name 'locations'
  set_primary_key :loc_id
  has_many :legacy_equipments
end
