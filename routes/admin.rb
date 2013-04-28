require 'sinatra'
root = File.dirname(File.dirname(File.realpath(__FILE__)))
require "#{root}/models.rb"

configure do
  # set root one level up, since this routes file is inside subdirectory
  set :root, root
  set :views, Proc.new { File.join(root, 'views/admin') }
end

use Rack::Auth::Basic, 'WoodEgg Admin' do |username, password|
  @@person = Person.find_by_email_pass(username, password)
end

before do
  redirect '/' unless @@person.admin?
  @person = @@person
end

get '/' do
  @pagetitle = 'admin home'
  erb :home
end

