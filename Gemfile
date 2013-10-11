source 'https://rubygems.org'

gem 'acts_as_list'                   # plugin for creating sortable lists
gem 'cancan'                         # authorization
gem 'devise'                         # authentication
gem 'draper'                         # model/view decorators (presenters)
gem 'foreigner'                      # foreign key constraints
gem 'gon'                            # javascript data passing
gem 'ice_cube'                       # date/time recurrences
gem 'jquery-rails'                   # jQuery javascript integration
gem 'kaminari'                       # pagination
gem 'mysql2'                         # mysql db driver
gem 'nested_form'                    # dynamic nested form helper
gem 'nokogiri'
gem 'pg'                             # postgres db driver
gem 'rails', '3.2.14'                # rails
gem 'rolify'                         # role management
gem 'ruby-graphviz', require: false
gem 'simple_form'                    # form builder
gem 'strip_attributes'               # strips model attributes, and converts blanks to nil
#gem 'strong_parameters'              # rails 4.0 type mass-assignment protection
#gem 'workflow'                       # state machine library
gem 'workflow', git: "https://github.com/jamezilla/workflow.git", ref: 'dbdfa22ca83772a260701f42b3f8e431f7ad6c8b'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'bootstrap-sass', '~> 2.3.2.0' # CSS generator
  gem 'coffee-rails'                 # coffee script integration
  gem 'font-awesome-sass-rails'      # Font Awesome fonts
  gem 'jquery-ui-rails'              # jQuery UI libraries
  gem 'sass-rails', '~> 3.2'         # CSS generator
  gem 'select2-rails'
  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'awesome_print'                # pretty object printer
  gem 'guard'
  gem 'guard-livereload'
  gem 'guard-minitest'
  gem 'immigrant'                    # migration generator for foreign keys
  gem 'progress_bar'
  gem 'pry-rails'                    # rails console on steroids
  gem 'quiet_assets'                 # stop the log diarrhea
  gem 'rack-livereload'
  gem 'thin'                         # web server
end

group :test do
  gem 'database_cleaner'             # for creating a clean test database before each test
  gem 'factory_girl_rails'           # factories - instead of fixtures
  gem "minitest-rails"               # minitest test framework
  gem 'minitest-rails-capybara'
end
