require 'sinatra'
require 'rvm'
require 'sequel'
require 'sqlite3'

module Hob
end

require_relative 'hob/web'
require_relative 'hob/world'
require_relative 'hob/tasks'
