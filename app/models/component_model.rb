class ComponentModel < ActiveRecord::Base

  ## Macros ##

  include Autocomplete
  resourcify
  strip_attributes


  ## Associations ##

  belongs_to :brand,      :inverse_of => :component_models
  has_many   :components, :inverse_of => :component_model
  has_many   :kits, :through => :components, :dependent => :destroy
  has_and_belongs_to_many :categories


  ## Validations ##

  validates :name, :presence => true
  validates :name, :uniqueness => {:scope => :brand_id, :case_sensitive => false}
  validates_presence_of :brand


  ## Mass-assignable attributes ##

  attr_accessible(:brand_id,
                  :category_ids,
                  :description,
                  :name,
                  :training_required)

  ## Class Methods ##

  def self.checkoutable
    joins(:kits).where("kits.tombstoned = ? AND kits.checkoutable = ?", false, true).uniq
  end

  # TODO: implement this
  # def self.reservable(from_date, to_date)
  # end

  def self.brand(brand_id)
    joins(:brand).where('brands.id = ?', brand_id.to_i)
  end

  # TODO: test this
  def self.category(category_id)
    joins(:categories).where('categories.id = ?', category_id.to_i)
  end


  ## Instance Methods ##

  def asset_tags
    components.map(&:asset_tag)
  end

  def available_checkoutable_kits(starts_at, ends_at, location = nil)
    all_kits         = checkoutable_kits.includes(:loans).order("loans.ends_at ASC")
    all_kits         = all_kits.where("location_id = ?", location.id) if location
    unavailable_kits = unavailable_checkoutable_kits(starts_at, ends_at, location)

    return all_kits - unavailable_kits
  end

  # returns a list of checkout locations which have business hours
  def checkout_locations
    locations = kits.collect { |k| k.location }
    locations.uniq!
    locations.select { |l| l.business_hours.count > 0 }
  end

  def checkoutable?
    kits.checkoutable.count > 0
  end

  def checkoutable_kits
    kits.checkoutable.uniq
  end

  # TODO: test this returns a JSON object with the available checkout
  # days for each kit (for pick up days), dates open (for return
  # days), grouped by location. Consumed by the javascript date picker
  def dates_checkoutable_for_datepicker(days_out = 90)
    locations = {}

    # roll up the kits, with their location and dates reservable
    checkoutable_kits.each do |kit|
      loc_id = kit.location.id

      # initialize this location if it doesn't exist
      if locations[loc_id].nil?
        locations[loc_id] = { 'kits' => [] }
      end

      # create the data structure for this kit
      kit_hash = {
        'kit_id' => kit.id,
        'days_reservable' => kit.dates_checkoutable_for_datepicker(days_out)
      }

      # add it to the collection of kits in this location
      locations[loc_id]['kits'] << kit_hash
    end

    # roll up the locations and their dates open
    locations.keys.each do |i|
      locations[i]['dates_open'] = Location.find(i).dates_open_for_datepicker(days_out)
    end

    return locations
  end

  # callback to populate :autocomplete
  def generate_autocomplete
    # we'll martial brand into the autocomplete field since it's
    # natural to search by brand
    s = "#{ brand } #{ name }"
    s = s.truncate(45, omission: "", separator: " ") if s.length > 45
    self.autocomplete = self.class.normalize(s)
  end

  def training_required?
    training_required
  end

  def to_s
    name
  end

  def to_param
    "#{ id } #{ brand } #{ name }".parameterize
  end

  def unavailable_checkoutable_kits(starts_at, ends_at, location = nil)
    q = checkoutable_kits.loaned_between(starts_at, ends_at)
    q = q.where("location_id = ?", location.id) if location
    return q
  end

end
