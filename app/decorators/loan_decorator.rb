class LoanDecorator < ApplicationDecorator
  decorates :loan
  decorates_association :approver,      with: UserDecorator
  decorates_association :check_in_inventory_record
  decorates_association :check_out_inventory_record
  decorates_association :client,        with: UserDecorator
  #decorates_association :in_attendant,  with: UserDecorator
  decorates_association :kit
  decorates_association :location
  #decorates_association :out_attendant, with: UserDecorator

  delegate :canceled?, :checked_out?, :checked_in?, :missing?, :pending?, :rejected?, :requested?

  def approver
    user = object.approver
    if user == User.system_user
      user = h.t("values.loan.system_approval")
    end
    coalesce(user)
  end

  def cancel_path
    if object.out_at
      h.loan_path(object)
    elsif (object.starts_at && object.id)
      h.reservation_path(object)
    elsif object.kit
      h.kit_path(object.kit)
    elsif object.component_model
      h.component_model_path(object.component_model)
    else
      h.component_models_path
    end
  end

  def ends_at
    coalesce(h.l(object.ends_at, :format => :tabular))
  end

  # def in_attendant
  #   coalesce(object.in_attendant)
  # end

  def in_at
    if object.in_at
      h.l(object.in_at, :format => :tabular)
    else
      h.content_tag "span", class: "loan not_checked_in" do
        coalesce(h.t('loan.not_checked_in'))
      end
    end
  end

  def late
    to_yes_no(object.late)
  end

  # def out_attendant
  #   coalesce(object.out_attendant)
  # end

  def out_at
    if object.out_at
      h.l(object.out_at, :format => :tabular)
    else
      h.content_tag "span", class: "loan not_checked_out" do
        coalesce(h.t('loan.not_checked_out'))
      end
    end
  end

  def renewals
    object.renewals.to_s
  end

  def starts_at
    coalesce(h.l(object.starts_at, :format => :tabular))
  end

  def state
    h.content_tag "span", class: "loan_state #{object.current_state}"  do
      h.t("loan.state.#{ object.current_state }").html_safe
    end
  end

  def to_link
    h.link_to(object.id.to_s, h.loan_path(object))
  end

  def to_s
    object.id.to_s
  end

end
