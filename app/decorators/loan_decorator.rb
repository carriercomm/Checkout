class LoanDecorator < ApplicationDecorator
  decorates :loan
  decorates_association :approver
  decorates_association :client
  decorates_association :in_assistant
  decorates_association :kit
  decorates_association :out_assistant

  def approver
    coalesce(source.approver)
  end

  def cancel_path
    if source.out_at
      h.loan_path(source)
    elsif source.starts_at
      h.reservation_path(source)
    elsif source.kit
      h.kit_path(source.kit)
    elsif source.component_model
      h.component_model_path(source.component_model)
    else
      h.component_models_path
    end
  end

  def ends_at
    coalesce(h.l(source.ends_at, :format => :tabular))
  end

  def in_assistant
    coalesce(source.in_assistant)
  end

  def in_at
    if source.in_at
      h.l(source.in_at, :format => :tabular)
    else
      coalesce(h.t('loan.not_checked_in'))
    end
  end

  def late
    to_yes_no(source.late)
  end

  def out_assistant
    coalesce(source.out_assistant)
  end

  def out_at
    if source.out_at
      h.l(source.out_at, :format => :tabular)
    else
      coalesce(h.t('loan.not_checked_out'))
    end
  end

  def starts_at
    coalesce(h.l(source.starts_at, :format => :tabular))
  end

  def state
    h.t("loan.state.#{ source.state }").html_safe
  end

end
