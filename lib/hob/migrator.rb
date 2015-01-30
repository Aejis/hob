require 'sequel'
require 'sqlite3'

module Hob
  class Migrator
    def self.migrate(version = nil)
      Sequel.extension :migration

      migrations_dir = File.join(File.dirname(__FILE__), 'migrations')

      if version
        puts "Migrating to version #{version}"
        Sequel::Migrator.run(World.db, migrations_dir, target: version)
      else
        puts 'Migrating to latest'
        Sequel::Migrator.run(World.db, migrations_dir)
      end
    end
  end
end
