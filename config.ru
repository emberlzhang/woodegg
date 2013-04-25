require 'sinatra/base'
require './models.rb'

require './routes/qa.rb'
require './routes/editor.rb'
require './routes/cleaner.rb'
require './routes/woodegg.com.rb'

use Rack::MethodOverride

map('/qa') { run WoodEggQA }
map('/ed') { run WoodEggEditor }
map('/clean') { run WoodEggCleaner }
map('/') { run WoodEggDotCom }

