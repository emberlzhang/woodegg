#encoding: utf-8

class WoodEggEditor < Sinatra::Base

  configure do
    # set root one level up, since this routes file is inside subdirectory
    set :root, File.dirname(File.dirname(File.realpath(__FILE__)))
    set :views, Proc.new { File.join(root, 'views/editor') }
  end

  use Rack::Auth::Basic, 'WoodEgg Editor' do |username, password|
    @@editor = Editor.find_by_email_pass(username, password)
  end

  before do
    redirect '/contact' if @@editor.nil?    # HACK: should say to contact me for password
    @editor = @@editor
    @edcc = @editor.countries
    redirect '/about' unless @edcc.size > 0 # HACK: should say they are not a Wood Egg editor
  end

  get '/' do
    if @edcc.size == 1
      redirect "/ed/#{@edcc.pop.downcase}"
    else
      @pagetitle = @editor.name
      erb :choose_country
    end
  end

  # /ed/th /ed/sg etc
  get Regexp.new(Countries.routemap) do |cc|
    @country_code = cc
    @ccode = cc.upcase
    @cname = Countries.hsh[@ccode]
    @country_name = @cname.gsub(' ', '&nbsp;')
    @questions = Question.needing_essays_for_country(@ccode)
    @topichash = Question.topichash(@ccode)
    @topicnest = Question.topicnest(@questions, @topichash)
    @pagetitle = @cname
    erb :questions
  end

  get '/question/:id' do
    @q = Question[params[:id]]
    redirect('/ed/', 301) if @q.nil?
    @ccode = @q.country
    @cname = Countries.hsh[@ccode]
    @pagetitle = @q.question
    erb :question
  end

  post '/essay' do
    x = Essay.find(editor_id: @editor.id, question_id: params[:question_id])
    if x.nil?
      cc = Question[params[:question_id]].country
      b = Book[country: cc]
      x = Essay.create(editor_id: @editor.id, question_id: params[:question_id], book_id: b.id, started_at: Time.now)
    end
    redirect "/ed/essay/#{x.id}"
  end

  get '/essay/:id' do
    @essay = Essay[params[:id]]
    redirect '/' if @essay.nil?
    @question = @essay.question
    @pagetitle = @question.question
    @answers = @question.answers
    @cname = Countries.hsh[@question.country]
    @subtopic = @question.template_question.subtopic
    erb :essay
  end

  post '/essay/:id' do
    x = Essay[params[:id]]
    if params[:submit] =~ /FINISH/
      x.update(content: params[:content], finished_at: Time.now)
      redirect '/ed/essays/finished'
    else
      x.update(content: params[:content])
      redirect "/ed/essay/#{x.id}"
    end
  end

  get '/essays/unfinished' do
    @pagetitle = 'Unfinished'
    @essays = @editor.essays_unfinished
    erb :essays
  end

  get '/essays/finished' do
    @pagetitle = 'Finished'
    @essays = @editor.essays_finished
    erb :essays
  end

  get '/help' do
    erb :help
  end

end
