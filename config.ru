require 'sinatra/base'
require './mailconfig.rb'
require './models.rb'

OTH_MAP = '/a'
require 'oth'
require './routes/woodegg.com.rb'
require './routes/a.rb'

use Rack::MethodOverride

map(OTH_MAP) { run WoodEggA }
map('/') { run WoodEggDotCom }

# NOT NEEDED UNTIL NEXT RESEARCH BEGINS:
#require './routes/qa.rb'
#require './routes/editor.rb'
#require './routes/cleaner.rb'
#map('/qa') { run WoodEggQA }
#map('/ed') { run WoodEggEditor }
#map('/clean') { run WoodEggCleaner }
