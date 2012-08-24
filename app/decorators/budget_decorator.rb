class BudgetDecorator < ApplicationDecorator
  decorates :budget

  allows :date_end, :date_start, :name, :number

  def display_date
    if !!model.date_start && !!model.date_end
      return "#{ model.date_start.year }-#{ model.date_end.year }"
    else
      return "Unknown"
    end
  end

  def date_end
    val_or_space(model.date_end)
  end

  def date_start
    val_or_space(model.date_start)
  end

  def name
    val_or_space(model.name)
  end

  def number
    val_or_space(model.number)
  end

  def to_s
    "#{ number } #{ name } (#{ display_date.rjust(9) })"
  end

end
