require 'pathname'
require 'sequel'

module Hob
  class Migrator
    def self.migrate(version = nil)
      Sequel.extension :migration
      
      if version
        puts "Migrating to version #{version}"
        Sequel::Migrator.run(World.db, "./migrations", target: version)
      else
        puts "Migrating to latest"
        Sequel::Migrator.run(World.db, "./migrations")
      end
    end
  end
end
