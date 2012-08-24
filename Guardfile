# guard 'spork', :minitest => true, :minitest_env => { 'RAILS_ENV' => 'test' }, :test_unit => false do
#   watch('config/application.rb')
#   watch('config/environment.rb')
#   watch('config/environments/test.rb')
#   watch(%r{^config/initializers/.+\.rb$})
#   watch('Gemfile')
#   watch('Gemfile.lock')
#   watch('test/test_helper.rb') { :minitest }
# end

guard 'minitest' do
  # with Minitest::Unit
  watch(%r|^test/(.*)\/?(.*)_test\.rb$|)
  watch(%r|^lib/(.*)([^/]+)\.rb$|)      { |m| "test/#{m[1]}test_#{m[2]}.rb" }
  watch(%r|^test/minitest_helper\.rb$|) { "test" }
  watch(%r|^test/factories\.rb$|)       { "test" }

  # with Minitest::Spec
  # watch(%r|^spec/(.*)_spec\.rb|)
  # watch(%r|^lib/(.*)([^/]+)\.rb|)     { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  # watch(%r|^spec/spec_helper\.rb|)    { "spec" }

  # Rails 3.2
  watch(%r|^app/controllers/(.*)_controller\.rb$|) { |m| "test/acceptance/#{m[1]}_test.rb" }
  watch(%r|^app/decorators/(.*)_decorator\.rb$|) { |m| "test/acceptance/#{m[1]}s_test.rb" }
  watch(%r|^app/helpers/(.*)\.rb$|)     { |m| "test/helpers/#{m[1]}_test.rb" }
  watch(%r|^app/models/(.*)\.rb$|)      { |m| "test/unit/#{m[1]}_test.rb" }
  watch(%r|^app/views/(.*)\/(.*)\.erb$|) { |m| "test/acceptance/#{m[1]}_test.rb" }
end
