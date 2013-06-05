include ERB::Util

class WoodEggA < Oth

  configure do
    # set root one level up, since this routes file is inside subdirectory
    set :root, File.dirname(File.dirname(File.realpath(__FILE__)))
    set :views, Proc.new { File.join(root, 'views/a') }
  end

  before Oth::ROUTEREG do
    oth!
  end
  
  get '/' do
    @pagetitle = 'Wood Egg account'
    erb :home
  end

end
