class SplitComponentModel
  extend  ActiveModel::Naming
  include ActiveModel::Validations

  attr_accessor :component_models, :root_component_model, :root_component_model_id

  validate :all_component_models_okay

  # HACK HACK: this is just to appease nested_form, but this is a terrible hack.
  def self.reflect_on_association(association)
    return ComponentModel
  end

  def all_component_models_okay
    component_models.each do |component_model|
      errors.add component_model.errors unless component_model.valid?
    end
  end

  def attributes=(attrs)
    attrs && attrs.each_pair { |name, value| self.send("#{name}=", value) }
  end

  # This is required by SimpleForm and Rails for non-ActiveRecord nested attributes
  def component_models_attributes=(attributes)
    attributes.each do |index, attrs|
      # if this is a delete operation, we need to handle the attribute separately
      destructo = (attrs.delete("_destroy") == "true") ? true : false

      # get the id of the component, if there is one
      component_model_id = attrs.delete("id").try(:to_i)

      # look up the component_model or create a new one
      component_model = ComponentModel.where(id: component_model_id).first_or_initialize

      # either update it or delete it
      if destructo && !component_model.new_record?
        component_model.destroy()
      else
        component_model.update_attributes(attrs)

        # add it to the collection if it doesn't exist already
        unless component_models.include?(component_model)
          self.component_models << component_model
        end
      end
    end
  end

  def component_models
    @component_models ||= []
  end

  # def component_models=(incoming_data)
  #   Rails.logger.debug ">>>>>>>>>>>>>>>"
  #   Rails.logger.debug caller[0]
  #   Rails.logger.debug incoming_data.inspect

  #   incoming_data.each do |incoming|
  #     if incoming.respond_to? :attributes
  #       @component_models << incoming unless @component_models.include? incoming
  #     else
  #       if incoming[:id]
  #         target = @component_models.select { |t| t.id == incoming[:id] }
  #       end
  #       if target
  #         target.attributes = incoming
  #       else
  #         @component_models << Component_Model.new(incoming)
  #       end
  #     end
  #   end
  # end

  def initialize(attrs={})
    self.attributes = attrs
  end

  def new_record?
    true
  end

  def persisted?
    false
  end

  def root_component_model=(component_model)
    @root_component_model = component_model
    component_models << component_model
    self
  end

  def root_component_model_id
    root_component_model.try(:id)
  end

  def root_component_model_id=(id)
    self.root_component_model = ComponentModel.includes(:brand).find(id.to_i)
    self
  end

  def save
    ActiveRecord::Base.transaction do
      return false unless component_models.all?(&:valid?) && component_models.all?(&:save)

      # add the new components to kits containing the root_component_model
      new_components = component_models - [root_component_model]

      root_component_model.kits.each do |k|
        new_components.each {|c| k.add_component c }
        unless k.save
          errors[:base] << "Could not add components to kit: #{k.to_s}"
        end
      end
    end
    return true
  end

  def to_key
    [object_id]
  end

  def to_model
    self
  end

  def to_param
    nil
  end
end
