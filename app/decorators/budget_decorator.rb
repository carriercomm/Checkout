class BudgetDecorator < ApplicationDecorator
  decorates :budget
  delegate :ends_at, :name, :number, :starts_at

  def display_date
    if !!object.starts_at && !!object.ends_at
      return "#{ object.starts_at.year }-#{ object.ends_at.year }"
    else
      return "Unknown"
    end
  end

  def ends_at
    coalesce(object.ends_at)
  end

  def starts_at
    coalesce(object.starts_at)
  end

  def name
    coalesce(object.name)
  end

  def number
    coalesce(object.number)
  end

  def to_select2_json
    {
      :id   => id,
      :text => to_s
    }
  end

  def to_link
    h.link_to(number, h.budget_path(object))
  end

  def to_s
    "#{ number } #{ name } (#{ display_date.rjust(9) })"
  end

end
