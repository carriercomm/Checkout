class Training < ActiveRecord::Base

  ## Macros ##

  resourcify
  strip_attributes


  ## Associations ##

  belongs_to :component_model, :inverse_of => :trainings
  belongs_to :user,            :inverse_of => :trainings


  ## Validations ##

  validates_presence_of :component_model
  validates_presence_of :user
  validates :user_id, :uniqueness => {:scope => :component_model_id}

end
