#encoding: utf-8
include ERB::Util

class WoodEggQA < Sinatra::Base

  configure do
    # set root one level up, since this routes file is inside subdirectory
    set :root, File.dirname(File.dirname(File.realpath(__FILE__)))
    set :views, Proc.new { File.join(root, 'views/qa') }
  end

  use Rack::Auth::Basic, 'WoodEgg QA' do |username, password|
    @@researcher = Researcher.find_by_email_pass(username, password)
  end

  before do
    redirect '/contact' if @@researcher.nil?    # HACK: should say to contact me for password
    @researcher = @@researcher
    @qacc = @researcher.countries
  end

  get '/' do
    if @qacc.size == 1
      redirect "/qa/#{@qacc.pop.downcase}"
    else
      @pagetitle = @researcher.name
      erb :choose_country
    end
  end

  get Regexp.new(Countries.routemap) do |cc|
    @country_code = cc
    @ccode = cc.upcase
    @cname = Countries.hsh[@ccode]
    @country_name = @cname.gsub(' ', '&nbsp;')
    @topics = @researcher.topics_unfinished
    erb :topics
  end

  get Regexp.new(Countries.routemap2) do |cc, topic_id|
    @country_code = cc
    @ccode = cc.upcase
    @cname = Countries.hsh[@ccode]
    @country_name = @cname.gsub(' ', '&nbsp;')
    @topic = Topic[topic_id]
    @subtopics = Subtopic.available_for_country_and_topic(@ccode, topic_id)
    @questions_i_answered = @researcher.question_ids_answered
    erb :subtopics
  end

  get '/answers/unfinished' do
    @pagetitle = 'Unfinished'
    @answers = @researcher.answers_unfinished
    erb :answers
  end

  get '/answers/finished' do
    @pagetitle = 'Finished'
    @answers = @researcher.answers_finished
    erb :answers
  end

  get '/question/:id' do
    @q = Question[params[:id]]
    redirect('/qa/', 301) if @q.nil?
    @ccode = @q.country
    @cname = Countries.hsh[@ccode]
    erb :question
  end

  post '/answer' do
    a = Answer.find(researcher_id: @researcher.id, question_id: params[:question_id])
    if a.nil?
      a = Answer.create(researcher_id: @researcher.id, question_id: params[:question_id], started_at: Time.now)
    end
    redirect "/qa/answer/#{a.id}"
  end

  get '/answer/:id' do
    @answer = Answer[params[:id]]
    redirect '/' if @answer.nil?
    @question = @answer.question
    @cname = Countries.hsh[@question.country]
    @subtopic = @question.template_question.subtopic
    erb :answer
  end

  post '/answer/:id' do
    a = Answer[params[:id]]
    if params[:submit] =~ /FINISH/
      a.update(answer: params[:answer], sources: params[:sources], finished_at: Time.now)
      redirect '/qa/answers/finished'
    else
      a.update(answer: params[:answer], sources: params[:sources])
      redirect "/qa/answer/#{a.id}"
    end
  end

  get '/help' do
    erb :help
  end

end
