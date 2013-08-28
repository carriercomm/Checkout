class Training < ActiveRecord::Base

  ## Macros ##

  strip_attributes


  ## Associations ##

  belongs_to :component_model, :inverse_of => :trainings
  belongs_to :user,            :inverse_of => :trainings


  ## Validations ##

  validates :component_model, :presence => true
  validates :user,            :presence => true
  validates :user_id,         :uniqueness => {:scope => :component_model_id}

end
