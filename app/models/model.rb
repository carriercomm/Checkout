class Model < ActiveRecord::Base

  belongs_to :brand
  has_many   :parts
  has_many   :kits, :through => :parts
  has_and_belongs_to_many :categories

  default_scope eager_load(:brand, :kits).order("brands.name ASC, models.name ASC")

  def self.tombstoned
    joins(:parts => :kit).where("kits.tombstoned = ?", true).uniq
  end

  def self.not_checkoutable
    joins(:parts => :kit ).where("kits.checkoutable = ?", false).uniq
  end

  def self.checkoutable
    joins(:parts => :kit ).where("kits.tombstoned = ? AND kits.checkoutable = ?", false, true).uniq
  end

  # TODO: implement this
  def self.reservable(from_date, to_date)
    
  end

  def self.brand(brand_id)
    joins(:brand).where('brands.id = ?', brand_id.to_i)
  end

  def self.category(category_id)
    joins(:categories).where('categories.id = ?', category_id.to_i)
  end

  def checkoutable?
    kits.where(:tombstoned => false, :checkoutable => true).count > 0
  end

  # TODO: implement reservable?

  def to_s
    name
  end

  def to_param
    "#{ id } #{ brand } #{ name }".parameterize
  end

end

=begin
m1 = Category.find(1).models
m2 = Model.category(1)

m1.reject { |x| m2.include? x }
=end
