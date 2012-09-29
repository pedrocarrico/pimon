require 'sinatra'
require './pimon'

root_dir = File.dirname(__FILE__) + "/.."

set :environment, :development
set :root,  root_dir
set :app_file, File.join(root_dir, 'pimon.rb')
disable :run

run Pimon
