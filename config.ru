require 'sinatra/base'
require './models.rb'

require './routes/cleaner.rb'
require './routes/woodegg.com.rb'

use Rack::MethodOverride

map('/clean') { run WoodEggCleaner }
map('/') { run WoodEggDotCom }

