class BudgetDecorator < ApplicationDecorator
  decorates :budget
  delegate :ends_at, :name, :number, :starts_at

  def display_date
    if !!source.starts_at && !!source.ends_at
      return "#{ source.starts_at.year }-#{ source.ends_at.year }"
    else
      return "Unknown"
    end
  end

  def ends_at
    coalesce(source.ends_at)
  end

  def starts_at
    coalesce(source.starts_at)
  end

  def name
    coalesce(source.name)
  end

  def number
    coalesce(source.number)
  end

  def to_s
    "#{ number } #{ name } (#{ display_date.rjust(9) })"
  end

end
