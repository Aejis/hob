lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hob/version'

Gem::Specification.new do |spec|
  spec.name          = 'hob'
  spec.version       = Hob::VERSION::String
  spec.authors       = ['Andrey Savchenko', 'Denis Sergienko', 'Ihor Kroosh']
  spec.email         = ['andrey@aejis.eu']
  spec.summary       = %q{Hob the deployer}
  spec.description   = %q{Hob the deployer}
  spec.homepage      = 'https://github.com/Aejis/hob'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 2.0'

  spec.add_runtime_dependency('sinatra')
  spec.add_runtime_dependency('sequel')
  spec.add_runtime_dependency('daemons')
  spec.add_runtime_dependency('thor')
  spec.add_runtime_dependency('warden')
  spec.add_runtime_dependency('bcrypt')
  spec.add_runtime_dependency('sqlite3')
  spec.add_runtime_dependency('mustermann')
end
