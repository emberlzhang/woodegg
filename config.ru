require 'sinatra/base'
require './models.rb'

require './routes/editor.rb'
require './routes/cleaner.rb'
require './routes/woodegg.com.rb'

use Rack::MethodOverride

map('/ed') { run WoodEggEditor }
map('/clean') { run WoodEggCleaner }
map('/') { run WoodEggDotCom }

