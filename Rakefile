require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the jsonifier plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the jsonifier plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Jsonifier'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

namespace :db do
  desc "Creates the plugin test database defined in test/database.yml. Defaults to creating the defined MySQL database. To specify another engine, try something like 'rake db:create DB=sqlite'."
  task :create do
    require 'active_record'

    configurations = YAML::load(IO.read(File.dirname(__FILE__) + '/test/database.yml'))
    config = configurations[ENV['DB'] || 'mysql']

    # Only connect to local databases.
    if config['host'] == 'localhost' || config['host'].blank?
      begin
        ActiveRecord::Base.establish_connection(config)
        ActiveRecord::Base.connection
      rescue
        # If failed to connect, it probably means the database has
        # not been created so we can safely create it.
        case config['adapter']
        when 'mysql'
          begin
            ActiveRecord::Base.establish_connection(config.merge({'database' => nil}))
            ActiveRecord::Base.connection.create_database(config['database'])
            ActiveRecord::Base.establish_connection(config)
            p "MySQL #{config['database']} database succesfully created"
          rescue => e
            $stderr.puts "Couldn't create database for #{config.inspect}: #{e}"
          end
        when 'postgresql'
          `createdb "#{config['database']}" -E utf8`
        when 'sqlite'
          `sqlite "#{config['database']}"`
        when 'sqlite3'
          `sqlite3 "#{config['database']}"`
        else
          p "#{config['database']} already exists"
        end
      end
    end
  end
end