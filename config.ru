require 'sinatra/base'
require './models.rb'
require './routes/woodegg.com.rb'
use Rack::MethodOverride

map('/') { run WoodEggDotCom }
