class Model < ActiveRecord::Base

  #
  # Associations
  #

  belongs_to :brand,      :inverse_of => :models
  has_many   :components, :inverse_of => :model
  has_many   :kits, :through => :components
  has_and_belongs_to_many :categories


  #
  # Validations
  #

  validates :name, :presence => true
  validates_presence_of :brand


  #
  # Mass-assignable attributes
  #

  attr_accessible(:brand_id,
                  :description,
                  :name,
                  :training_required)

  # moved these over to kit, since they return somewhat confusing results here
  # def self.tombstoned
  #   joins(:kits).where("kits.tombstoned = ?", true).uniq
  # end
  # def self.not_checkoutable
  #   joins(:kits).where("kits.checkoutable = ?", false).uniq
  # end

  def self.checkoutable
    joins(:kits).where("kits.tombstoned = ? AND kits.checkoutable = ?", false, true).uniq
  end

  # TODO: implement this
  # def self.reservable(from_date, to_date)
  # end

  def self.brand(brand_id)
    joins(:brand).where('brands.id = ?', brand_id.to_i)
  end

  def self.category(category_id)
    joins(:categories).where('categories.id = ?', category_id.to_i)
  end

  def kit_asset_tags
    ats = components.collect { |c| [c.asset_tag, c.kit] }
    ats.sort_by! { |a| a.first }
  end

  def checkoutable?
    kits.checkoutable.count > 0
  end

  # TODO: implement reservable?

  def to_s
    name
  end

  def to_param
    "#{ id } #{ brand } #{ name }".parameterize
  end

end
