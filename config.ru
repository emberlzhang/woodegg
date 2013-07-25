require 'sinatra/base'
require './models.rb'

OTH_MAP = '/a'
require 'oth'
require './routes/woodegg.com.rb'
require './routes/a.rb'

use Rack::MethodOverride

map(OTH_MAP) { run WoodEggA }
map('/') { run WoodEggDotCom }

require './routes/qa.rb'
map('/qa') { run WoodEggQA }

# NOT NEEDED UNTIL WRITERS BEGIN:
#require './routes/writer.rb'
#map('/ed') { run WoodEggEditor }
#require './routes/cleaner.rb'
#map('/clean') { run WoodEggCleaner }
