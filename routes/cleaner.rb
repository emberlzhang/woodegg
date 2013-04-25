include ERB::Util

class WoodEggCleaner < Sinatra::Base

  configure do
    # set root one level up, since this routes file is inside subdirectory
    set :root, File.dirname(File.dirname(File.realpath(__FILE__)))
    set :views, Proc.new { File.join(root, 'views/cleaner') }
  end

  use Rack::Auth::Basic, 'WoodEgg Cleaner' do |username, password|
    @@person = Person.find_by_email_pass(username, password)
  end

  before do
    @person = @@person
    redirect '/contact' if @@person.nil?        # HACK: should say to contact me for password
    redirect '/about' unless @@person.cleaner?  # HACK: should say they are not a Wood Egg cleaner
  end

  get '/' do
    @howmany_uncleaned = Essay.howmany_uncleaned
    erb :home
  end

  get '/next' do
    e = Essay.next_uncleaned_for(@person.email)
    if e.nil?
      e = Essay.next_uncleaned
      if e.nil?
        redirect '/clean/'
      else
        e.update(cleaned_by: @person.email)
      end
    end
    redirect '/clean/essay/%d' % e.id
  end

  get '/essay/:id' do
    @essay = Essay[params[:id]]
    @question = @essay.question[:question]
    @country = Countries.hsh[@essay.question[:country]]
    @subtopic = @essay.question.template_question.subtopic[:subtopic]
    @topic = @essay.question.template_question.subtopic.topic[:topic]
    erb :essay
  end

  put '/essay/:id' do
    e = Essay[params[:id]]
    e.update(content: params[:content].strip)
    if params[:submit] =~ /FINISHED/
      e.update(cleaned_at: Time.now())
      if params[:submit] =~ /STOP/
	redirect '/clean/'
      else
	redirect '/clean/next'
      end
    end
    redirect '/clean/essay/%d' % e.id
  end

end
