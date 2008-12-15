$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'test/unit'

begin
  # Use Rails app's config and ActiveRecord if available.
  require File.dirname(__FILE__) + '/../../../../config/boot'
  Rails::Initializer.run
rescue LoadError
  # Otherwise just use installed ActiveRecord gem.
  require 'rubygems'
  require 'active_record'
end

require 'active_record/fixtures'

ActiveRecord::Base.configurations = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/debug.log')
ActiveRecord::Base.establish_connection(ENV['DB'] || 'mysql')

load(File.dirname(__FILE__) + '/schema.rb')

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + '/fixtures/'
$LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path)

class Test::Unit::TestCase #:nodoc:
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

  ActiveSupport::JSON.unquote_hash_key_identifiers = false
end