class Category < ActiveRecord::Base

  ## Mixins ##

  include Autocomplete

  ## Associations ##

  has_and_belongs_to_many :component_models


  ## Validations ##

  validates :name, :presence => true
  validates :name, :uniqueness => { :case_sensitive => false }


  ## Mass-assignable Attributes ##

  attr_accessible :name, :description


  ## Class methods ##

  def self.for_user(client)
    joins(:component_models => { :kits => { :groups => :users }}).where("users.username = ?", client.username).uniq
  end


  # scope :current, joins(<<-END_SQL
  #   INNER JOIN (SELECT component_id, MAX(created_at) AS max_created_at
  #    FROM inventory_records
  #    GROUP BY component_id) ir2 ON inventory_records.component_id = ir2.component_id AND inventory_records.created_at = ir2.max_created_at
  #   END_SQL
  # )


  # returns a list of related categories
  def self.suggest(category_ids)
    raise "catgory_ids must be an Array" unless category_ids.is_a? Array
    suggestions = []
    # get all the category objects for this bunch of ids
    current_categories = Category.includes(:component_models).joins(:component_models).find(category_ids)

    # iterate over the component_models associated with the categories
    current_categories.each do |c|
      # extract the categories of each component_model
      c.component_models.each { |m| suggestions << m.categories }
    end

    suggestions.flatten.uniq.sort - current_categories
  end

  ## Instance methods ##

  def to_param
    "#{ id } #{ name }".parameterize
  end

end
