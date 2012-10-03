class BudgetDecorator < ApplicationDecorator
  decorates :budget

  allows :ends_at, :starts_at, :name, :number

  def display_date
    if !!model.starts_at && !!model.ends_at
      return "#{ model.starts_at.year }-#{ model.ends_at.year }"
    else
      return "Unknown"
    end
  end

  def ends_at
    val_or_space(model.ends_at)
  end

  def starts_at
    val_or_space(model.starts_at)
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
