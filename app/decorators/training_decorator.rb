class TrainingDecorator < ApplicationDecorator
  decorates :training
  decorates_association :component_model
  decorates_association :user

  def created_at
    localize_unless_nil(model.created_at, :format => :tabular)
  end

end
