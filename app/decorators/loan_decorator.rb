class LoanDecorator < Draper::Base
  decorates :loan
  decorates_association :kit
  decorates_association :client
  decorates_association :approver
  decorates_association :out_assistant
  decorates_association :in_assistant

end
