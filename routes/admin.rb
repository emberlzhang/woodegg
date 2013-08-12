require 'erb'
include ERB::Util
require 'sinatra'
require 'kramdown'
root = File.dirname(File.dirname(File.realpath(__FILE__)))
require "#{root}/models.rb"

configure do
  set :root, root
  set :views, Proc.new { File.join(root, 'views/admin') }
end

use Rack::Auth::Basic, 'WoodEgg Admin' do |username, password|
  HTTPAuth.person = Person.find_by_email_pass(username, password)
end

before do
  redirect '/' unless HTTPAuth.person.admin?
  @person = HTTPAuth.person
end

# of submitted params, get only the ones with these keys
# USAGE:
#   Thought.update(just(%w(author_id contributor_id created_at source_url)))
def just(keyz)
  params.select {|k, v| keyz.include? k}
end


##################  HOME, PURCHASE PROOF, STATS

get '/' do
  @pagetitle = 'home'
  @userstats = Userstat.filter(:statkey.like 'proof%').all
  erb :home
end

post '/proof' do
  u = Userstat[params[:uid]]
  raise('no Userstat for %d' % params[:uid]) if u.nil?
  if params[:submit] == 'no'
    u.update(statkey: u.statkey.gsub('proof', 'nope'))
    redirect '/'
  else
    /proof-we13([a-z]{2})/.match u.statkey
    b = Book[country: $1.upcase]
    raise('no Book for %s' % $1.upcase) if b.nil?
    p = u.person
    raise('no Person for u %d with person_id %d' % [u.id, u.person_id]) if p.nil?
    c = p.customer
    # if they weren't a customer before, they are now!
    if c.nil?
      c = Customer.create(person_id: p.id)
      has_books = []
    else
      has_books = c.books
    end
    c.add_book(b) unless has_books.include? b
    c.email_post_proof(b)
    u.update(statkey: u.statkey.gsub('proof', 'bought'))
    redirect '/'
  end
end

get '/stats' do
  @pagetitle = 'stats'
  @grid = Countries.userstats_grid
  @person_url_d = WoodEgg.config['woodegg_person_url']
  @newest = Userstat.newest_woodegg
  erb :stats
end

get '/stats/:country/:val' do
  @country_code = params[:country]
  @country_name = Countries.hsh[@country_code] || 'Any Country'
  @val = params[:val]
  @pagetitle = @country_name + ' ' + @val
  @people = Person.country_val(@country_code, @val)
  @person_url_d = WoodEgg.config['woodegg_person_url']
  erb :stats2
end



###################### BOOKS

get '/books' do
  @pagetitle = 'books'
  @books_not_done = Book.not_done
  @books_done = Book.done
  erb :books
end

get %r{\A/book/([0-9]+)\Z} do |id|
  @book = Book[id]
  @pagetitle = @book.short_title
  @done = @book.done?
  unless @done
    @questions_missing_essays = @book.questions_missing_essays
    @essays_unedited = @book.essays_unedited.all
  end
  @questions = @book.questions
  @essays = @book.essays
  @researchers = @book.researchers
  @writers = @book.writers
  @editors = @book.editors
  erb :book
end

put %r{\A/book/([0-9]+)\Z} do |id|
  b = Book[id]
  b.update(just(%w(title isbn asin leanpub intro salescopy)))
  redirect '/book/%d' % b.id
end

get %r{\A/book/([0-9]+)/questions\Z} do |id|
  @book = Book[id]
  @pagetitle = @book.short_title + ' questions'
  @topicnest = Question.topicnest(@book.questions, Question.topichash(@book.country))
  erb :questions
end

get %r{\A/book/([0-9]+)/essays\Z} do |id|
  @book = Book[id]
  @pagetitle = @book.short_title + ' essays'
  @essays = @book.essays
  @question_for_essay = Question.for_these(@essays)
  erb :essays
end


################ ESSAYS, ANSWERS, QUESTIONS

get '/answers' do
  @pagetitle = 'ANSWERS - summary by status'
  @unjudged_count = Answer.unjudged_count
  @unfinished_count = Answer.unfinished.count
  erb :answers_summary
end

get '/answers/unfinished' do
  @answers = Answer.unfinished
  @pagetitle = 'UNFINISHED ANSWERS'
  erb :answers_unfinished
end

get '/answers/unjudged' do
  @answers = Answer.unjudged
  @pagetitle = 'UNJUDGED ANSWERS'
  erb :answers_unjudged
end

get '/answer/unjudged' do
  @unjudged_count = Answer.unjudged_count
  redirect '/answers' if @unjudged_count == 0
  @answer = Answer.unjudged_next
  @question = @answer.question
  @researcher = @answer.researcher
  @pagetitle = 'unjudged answer'
  erb :answer_unjudged
end

put %r{\A/answer/([0-9]+)/judge\Z} do |id|
  a = Answer[id]
  a.update(payable: (params[:payable] == 'yes'))
  redirect '/answer/unjudged'
end

get %r{\A/essay/([0-9]+)\Z} do |id|
  @essay = Essay[id]
  @pagetitle = 'essay #%d' % @essay.id
  erb :essay
end

put %r{\A/essay/([0-9]+)\Z} do |id|
  e = Essay[id]
  e.update(just(%w(editor_id started_at finished_at payable edited_at content edited)))
  redirect '/essay/%d' % e.id
end

get %r{\A/question/([0-9]+)\Z} do |id|
  @question = Question[id]
  @pagetitle = 'question #%d' % @question.id
  erb :question
end

get %r{\A/answer/([0-9]+)\Z} do |id|
  @answer = Answer[id]
  @pagetitle = 'answer #%d' % @answer.id
  @question = @answer.question
  @researcher = @answer.researcher
  erb :answer
end

put %r{\A/answer/([0-9]+)\Z} do |id|
  a = Answer[id]
  a.update(just(%w(started_at finished_at payable answer sources)))
  redirect '/answer/%d' % a.id
end



################## RESEARCHERS, WRITERS, EDITORS - each URL type together, since so similar

get '/researchers' do
  @pagetitle = 'researchers'
  @researchers = Researcher.all_people.sort_by(&:name)
  @without_books = Researcher.without_books
  erb :researchers
end

get '/writers' do
  @pagetitle = 'writers'
  @writers = Writer.order(:id).all
  @without_books = Writer.without_books
  erb :writers
end

get '/editors' do
  @pagetitle = 'editors'
  @editors = Editor.order(:id).all
  @without_books = Editor.without_books
  erb :editors
end

get %r{\A/researcher/([0-9]+)\Z} do |id|
  @researcher = Researcher[id]
  @pagetitle = 'RESEARCHER: %s' % @researcher.name
  @person_url = WoodEgg.config['woodegg_person_url'] % @researcher.person_id
  @ok_to_delete = (@researcher.answers_dataset.count == 0) ? true : false
  @books2add = Book.filter(asin: nil).order(:id).all - @researcher.books
  erb :researcher
end

get %r{\A/writer/([0-9]+)\Z} do |id|
  @writer = Writer[id]
  @pagetitle = 'WRITER: %s' % @writer.name
  @person_url = WoodEgg.config['woodegg_person_url'] % @writer.person_id
  @books2add = Book.filter(asin: nil).order(:id).all - @writer.books
  erb :writer
end

get %r{\A/editor/([0-9]+)\Z} do |id|
  @editor = Editor[id]
  @pagetitle = 'EDITOR: %s' % @editor.name
  @person_url = WoodEgg.config['woodegg_person_url'] % @editor.person_id
  @books2add = Book.filter(asin: nil).order(:id).all - @editor.books
  erb :editor
end

get %r{\A/researcher/([0-9]+)/answers/(finished|unfinished|unpaid|unjudged)\Z} do |id,filtr|
  @researcher = Researcher[id]
  @pagetitle = "#{filtr} answers for #{@researcher.name}"
  @answers = @researcher.send("answers_#{filtr}")
  @question_for_answers = Question.for_these(@answers)
  erb :researcher_answers
end

get %r{\A/writer/([0-9]+)/essays/(finished|unfinished|unpaid|unjudged)\Z} do |id,filtr|
  @writer = Writer[id]
  @pagetitle = "#{filtr} essays for #{@writer.name}"
  @essays = @writer.send("essays_#{filtr}")
  @question_for_essays = Question.for_these(@essays)
  erb :writer_essays
end

post '/researchers' do
  x = Researcher.create(person_id: params[:person_id].to_i)
  redirect '/researcher/%d' % x.id
end

post '/writers' do
  x = Writer.create(person_id: params[:person_id].to_i)
  redirect '/writer/%d' % x.id
end

post '/editors' do
  x = Editor.create(person_id: params[:person_id].to_i)
  redirect '/editor/%d' % x.id
end

put %r{\A/researcher/([0-9]+)\Z} do |id|
  r = Researcher[id]
  r.update(just(%w(bio)))
  redirect '/researcher/%d' % r.id
end

put %r{\A/writer/([0-9]+)\Z} do |id|
  x = Writer[id]
  x.update(just(%w(bio)))
  redirect '/writer/%d' % x.id
end

post %r{\A/researcher/([0-9]+)/books\Z} do |id|
  r = Researcher[id]
  b = Book[params[:book_id]]
  r.add_book(b) if b
  redirect '/researcher/%d' % r.id
end

post %r{\A/writer/([0-9]+)/books\Z} do |id|
  x = Writer[id]
  b = Book[params[:book_id]]
  x.add_book(b) if b
  redirect '/writer/%d' % x.id
end

post %r{\A/editor/([0-9]+)/books\Z} do |id|
  x = Editor[id]
  b = Book[params[:book_id]]
  x.add_book(b) if b
  redirect '/editor/%d' % x.id
end

post %r{\A/writer/([0-9]+)/approval\Z} do |id|
  x = Writer[id]
  x.approve_finished_unjudged_essays
  redirect '/writer/%d' % x.id
end

post %r{\A/researcher/([0-9]+)/answers\Z} do |researcher_id|
  redirect "/researcher/#{researcher_id}" unless params[:question_id].to_i > 0
  a = Answer.create(question_id: params[:question_id],
		    researcher_id: researcher_id,
		    started_at: Time.now(),
		    finished_at: Time.now(),
		    payable: true)
  redirect '/answer/%d' % a.id
end

delete %r{\A/researcher/([0-9]+)\Z} do |id|
  x = Researcher[id]
  x.destroy
  redirect '/researchers'
end

delete %r{\A/writer/([0-9]+)\Z} do |id|
  x = Writer[id]
  x.destroy
  redirect '/writers'
end


######################## CUSTOMERS

get '/customers' do
  @pagetitle = 'all customers'
  @customers = Customer.order(:id).all
  @person_id = params[:person_id]
  erb :customers
end

post '/customers' do
  c = Customer.create(person_id: params[:person_id])
  redirect '/customer/%d' % c.id
end

get %r{\A/book/([0-9]+)/customers\Z} do |id|
  @book = Book[id]
  @pagetitle = 'customers of ' + @book.short_title
  @customers = @book.customers
  erb :customers
end

get %r{\A/customer/([0-9]+)\Z} do |id|
  @customer = Customer[id]
  @pagetitle = 'customer: ' + @customer.name
  @books = @customer.books
  @books_to_add = Book.where('id <= 16').order(:title).all - @books
  @person_url = WoodEgg.config['woodegg_person_url'] % @customer.person_id
  @sent = params[:sent]
  erb :customer
end

post %r{\A/customer/([0-9]+)/books\Z} do |id|
  c = Customer[id]
  has_books = c.books
  if params[:book_id] == 'all'
    Book.available.each do |b|
      c.add_book(b) unless has_books.include? b
    end
  else
    b = Book[params[:book_id]]
    unless b.nil?
      c.add_book(b) unless has_books.include? b
    end
  end
  redirect '/customer/%d' % c.id
end

post %r{\A/customer/([0-9]+)/email\Z} do |id|
  c = Customer[id]
  c.email_first
  redirect '/customer/%d?sent=sent' % c.id
end



############# TIDBITS AND TAGS

get '/tidbits' do
  @pagetitle = 'tidbits'
  if params[:tag_id]
    @tag = Tag[params[:tag_id]]
    @tidbits = @tag.tidbits
  else
    @tidbits = Tidbit.order(:id.desc).all
  end
  @all_tags = Tag.order(:id).all
  erb :tidbits
end

post '/tidbits' do
  t = Tidbit.create(created_at: Time.now())
  redirect '/tidbit/%d' % t.id
end

get %r{\A/tidbit/([0-9]+)\Z} do |id|
  @tidbit = Tidbit[id]
  @pagetitle = 'tidbit # %d' % @tidbit.id
  @all_tags = Tag.order(:id).all - @tidbit.tags
  erb :tidbit
end

put %r{\A/tidbit/([0-9]+)\Z} do |id|
  t = Tidbit[id]
  t.update(just(%w(created_at created_by headline url intro content)))
  redirect '/tidbit/%d' % t.id
end

delete %r{\A/tidbit/([0-9]+)\Z} do |id|
  t = Tidbit[id]
  t.destroy
  redirect '/tidbits'
end

post %r{\A/tidbit/([0-9]+)/tags\Z} do |id|
  t = Tidbit[id]
  # can post either tag_name, to make new, or tag_id, to use existing
  tag = nil
  if params[:tag_name].empty? == false
    tag = Tag.create(name: params[:tag_name])
  elsif params[:tag_id].to_i > 0
    tag = Tag[params[:tag_id]]
  end
  t.add_tag(tag) if tag
  redirect '/tidbit/%d' % t.id
end

post %r{\A/tidbit/([0-9]+)/questions\Z} do |id|
  t = Tidbit[id]
  t.add_question(Question[params[:question_id]])
  redirect '/tidbit/%d' % t.id
end

delete %r{\A/tidbit/([0-9]+)/tag/([0-9]+)\Z} do |id, tag_id|
  t = Tidbit[id]
  t.remove_tag(Tag[tag_id])
  redirect '/tidbit/%d' % t.id
end

delete %r{\A/tidbit/([0-9]+)/question/([0-9]+)\Z} do |id, question_id|
  t = Tidbit[id]
  t.remove_question(Question[question_id])
  redirect '/tidbit/%d' % t.id
end

################ UPLOADS

get '/uploads' do
  @uploads = Upload.order(Sequel.desc(:created_at), Sequel.desc(:researcher_id)).all
  @rnames = {}
  Researcher.all_people.each {|p| @rnames[p.id] = p.name}
  @pagetitle = 'UPLOADS'
  erb :uploads
end

get %r{\A/upload/([0-9]+)\Z} do |id|
  @upload = Upload[id]
  @downlink = ''
  if @upload.uploaded == 'y'
    @downlink = ' (<a href="' + @upload.url + '">click here to download</a>)'
  end
  @pagetitle = 'UPLOAD #%d' % id
  erb :upload
end

put %r{\A/upload/([0-9]+)\Z} do |id|
  u = Upload[id]
  u.update(notes: params[:notes], transcription: params[:transcription])
  redirect '/upload/%d' % id
end

