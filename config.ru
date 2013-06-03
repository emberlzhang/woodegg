require 'sinatra/base'
require './mailconfig.rb'
require './models.rb'

OTH_MAP = '/a'
require 'oth'
require './routes/qa.rb'
require './routes/editor.rb'
require './routes/cleaner.rb'
require './routes/woodegg.com.rb'
require './routes/a.rb'

use Rack::MethodOverride

map('/qa') { run WoodEggQA }
map('/ed') { run WoodEggEditor }
map('/clean') { run WoodEggCleaner }
map(OTH_MAP) { run WoodEggA }
map('/') { run WoodEggDotCom }

