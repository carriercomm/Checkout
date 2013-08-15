module Autocomplete
  extend ActiveSupport::Concern

  included do
    before_save :generate_autocomplete
  end

  # callback to populate :autocomplete
  def generate_autocomplete
    # you'll have to customize this
    s = self.name
    s = s.truncate(45, omission: "", separator: " ") if s.length > 45
    self.autocomplete = self.class.normalize(s)
  end

  module ClassMethods
    # turn strings into autocomplete keys
    def normalize(s)
      s = s.upcase
      s = s.gsub("'", "")
      s = s.gsub("&", " AND ")
      s = s.gsub(/[^A-Z0-9 ]/, " ")
      s = s.squish
      s
    end

    def search(query)
      query = normalize(query)
      return [] if query.blank?
      where("autocomplete LIKE ?", "%#{ query }%").order(:name)
    end
  end

end
