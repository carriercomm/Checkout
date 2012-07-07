ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require "minitest/autorun"
require "capybara/rails"
require "active_support/testing/setup_and_teardown"

DatabaseCleaner.strategy = :truncation

class MiniTest::Spec
  before :each do
    DatabaseCleaner.clean       # Truncate the database
    Capybara.reset_sessions!    # Forget the (simulated) browser state
    Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver
  end
end

class IntegrationTest < MiniTest::Spec
  include Rails.application.routes.url_helpers
  include Capybara::DSL
  register_spec_type(/Integration$/, self)
end

class HelperTest < MiniTest::Spec
  include ActiveSupport::Testing::SetupAndTeardown
  include ActionView::TestCase::Behavior
  register_spec_type(/Helper$/, self)
end

# Turn.config do |c|
#   # use one of output formats:
#   # :outline  - turn's original case/test outline mode [default]
#   # :progress - indicates progress with progress bar
#   # :dotted   - test/unit's traditional dot-progress mode
#   # :pretty   - new pretty reporter
#   # :marshal  - dump output as YAML (normal run mode only)
#   # :cue      - interactive testing
#   c.format  = :pretty
#   # turn on invoke/execute tracing, enable full backtrace
#   c.trace   = true
#   # use humanized test names (works only with :outline format)
#   c.natural = true
# end
