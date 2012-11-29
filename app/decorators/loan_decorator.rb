class LoanDecorator < ApplicationDecorator
  decorates :loan
  decorates_association :approver
  decorates_association :client
  decorates_association :in_assistant
  decorates_association :kit
  decorates_association :out_assistant

  def approver
    coalesce(model.approver)
  end

  def cancel_path
    if model.out_at
      h.loan_path(model)
    elsif model.starts_at
      h.reservation_path(model)
    elsif model.kit
      h.kit_path(model.kit)
    elsif model.component_model
      h.component_model_path(model.component_model)
    else
      h.component_models_path
    end
  end

  def ends_at
    coalesce(h.l(model.ends_at, :format => :tabular))
  end

  def in_assistant
    coalesce(model.in_assistant)
  end

  def in_at
    if model.in_at
      h.l(model.in_at, :format => :tabular)
    else
      coalesce(h.t('loan.not_checked_in'))
    end
  end

  def late
    to_yes_no(model.late)
  end

  def out_assistant
    coalesce(model.out_assistant)
  end

  def out_at
    if model.out_at
      h.l(model.out_at, :format => :tabular)
    else
      coalesce(h.t('loan.not_checked_out'))
    end
  end

  def starts_at
    coalesce(h.l(model.starts_at, :format => :tabular))
  end

  def state
    h.t("loan.state.#{ model.state }").html_safe
  end

end
