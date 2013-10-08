class Brand < ActiveRecord::Base

  ## Mixins ##

  include Autocomplete
  strip_attributes


  ## Associations ##

  has_many :component_models


  ## Validations ##

  validates :name, :presence   => true
  validates :name, :uniqueness => {:case_sensitive => false}


  ## Mass-assignable Attributes ##

  attr_accessible :name


  ## Class Methods ##

  def self.having_non_circulating_kits
    joins(:component_models => :kits).where("kits.workflow_state = 'non_circulating'").uniq
  end

  def self.having_circulating_kits
    joins(:component_models => :kits).where("kits.workflow_state = 'circulating'").uniq
  end


  def self.for_user(user)
    if Settings.clients_can_see_equipment_outside_their_groups || user.attendant? || user.admin?
      return scoped
    else
      return joins(:component_models => { :kits => { :groups => :memberships }})
                     .where("memberships.user_id = ?", user.id).uniq
    end
  end


  ## Instance Methods ##

  # TODO: move this to a decorator. something specific to select2
  def as_json(options={})
    {
      id: id,
      text: name
    }
  end

  def to_param
    "#{ id } #{ name }".parameterize
  end

  def to_s
    name
  end

end
