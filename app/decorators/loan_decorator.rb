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

  def ends_at
    coalesce(model.ends_at.try(:to_formatted_s, :tabular))
  end

  def in_assistant
    coalesce(model.in_assistant)
  end

  def in_at
    coalesce(model.in_at.try(:to_formatted_s, :tabular), h.t('loan.not_checked_in'))
  end

  def late
    to_yes_no(model.late)
  end

  def out_assistant
    coalesce(model.out_assistant)
  end

  def out_at
    coalesce(model.out_at.try(:to_formatted_s, :tabular), h.t('loan.not_checked_out'))
  end

  def starts_at
    coalesce(model.starts_at.try(:to_formatted_s, :tabular))
  end

  def state
    h.t("loan.state.#{ model.state }")
  end

end
