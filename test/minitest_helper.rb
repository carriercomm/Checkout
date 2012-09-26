ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)

require "minitest/autorun"
require "minitest/rails"
require "minitest/rails/capybara"
require "minitest-metadata"

Capybara.javascript_driver = :webkit_debug
DatabaseCleaner.strategy = :truncation
Warden.test_mode!

class MiniTest::Spec
  include Warden::Test::Helpers

  before :each do
    DatabaseCleaner.clean       # Truncate the database
    Warden.test_reset!          # logout any active users
    Capybara.use_default_driver #
    Capybara.reset_sessions!    # Forget the (simulated) browser state
  end

  # Will run the given code as the user passed in
  def as_user(user=nil, &block)
    current_user = user || Factory.create(:user)
    if request.present?
      sign_in(current_user)
    else
      login_as(current_user, :scope => :user)
    end
    block.call if block.present?
    return self
  end


  def as_visitor(user=nil, &block)
    current_user = user || Factory.stub(:user)
    if request.present?
      sign_out(current_user)
    else
      logout(:user)
    end
    block.call if block.present?
    return self
  end

end

class MiniTest::Rails::ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
