require 'erb'
include ERB::Util
require 'sinatra'
require 'kramdown'
root = File.dirname(File.dirname(File.realpath(__FILE__)))
require "#{root}/models.rb"
require "#{root}/mailconfig.rb"

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

get '/' do
  @pagetitle = 'home'
  erb :home
end

get '/books' do
  @pagetitle = 'books'
  @books_done = Book.done
  # @books_not_done = Book.not_done
  erb :books
end

get '/book/:id' do
  @book = Book[params[:id]]
  @pagetitle = @book.short_title
  @done = @book.done?
  unless @done
    @questions_missing_essays = @book.questions_missing_essays
    @essays_uncleaned = @book.essays_uncleaned.all
  end
  @questions = @book.questions
  @essays = @book.essays
  @editors = @book.editors
  @researchers = @book.researchers
  erb :book
end

put '/book/:id' do
  b = Book[params[:id]]
  b.update(just(%w(title isbn asin leanpub intro salescopy)))
  redirect '/book/%d' % b.id
end

get '/book/:id/questions' do
  @book = Book[params[:id]]
  @pagetitle = @book.short_title + ' questions'
  @topicnest = Question.topicnest(@book.questions, Question.topichash(@book.country))
  erb :questions
end

get '/book/:id/essays' do
  @book = Book[params[:id]]
  @pagetitle = @book.short_title + ' essays'
  @essays = @book.essays
  @question_for_essay = Question.for_these(@essays)
  erb :essays
end

get '/essay/:id' do
  @essay = Essay[params[:id]]
  @pagetitle = 'essay #%d' % @essay.id
  erb :essay
end

put '/essay/:id' do
  e = Essay[params[:id]]
  e.update(just(%w(started_at finished_at payable cleaned_at cleaned_by content comment)))
  redirect '/essay/%d' % e.id
end

get '/question/:id' do
  @question = Question[params[:id]]
  @pagetitle = 'question #%d' % @question.id
  erb :question
end

get '/answer/:id' do
  @answer = Answer[params[:id]]
  @pagetitle = 'answer #%d' % @answer.id
  @question = @answer.question
  @researcher = @answer.researcher
  erb :answer
end

put '/answer/:id' do
  a = Answer[params[:id]]
  a.update(just(%w(started_at finished_at payable answer sources)))
  redirect '/answer/%d' % a.id
end

get '/editor/:id' do
  @editor = Editor[params[:id]]
  @pagetitle = 'EDITOR: %s' % @editor.name
  @person_url = WoodEgg.config['person_url'] % @editor.person_id
  erb :editor
end

get %r{/editor/([0-9]+)/essays/(finished|unfinished|unpaid|unjudged)} do |id,filtr|
  @editor = Editor[id]
  @pagetitle = "#{filtr} essays for #{@editor.name}"
  @essays = @editor.send("essays_#{filtr}")
  @question_for_essays = Question.for_these(@essays)
  erb :editor_essays
end

put '/editor/:id' do
  e = Editor[params[:id]]
  e.update(just(%w(bio)))
  redirect '/editor/%d' % e.id
end

post '/editor/:id/approval' do
  e = Editor[params[:id]]
  e.approve_finished_unjudged_essays
  redirect '/editor/%d' % e.id
end

get '/researcher/:id' do
  @researcher = Researcher[params[:id]]
  @pagetitle = 'RESEARCHER: %s' % @researcher.name
  @person_url = WoodEgg.config['person_url'] % @researcher.person_id
  erb :researcher
end

get %r{/researcher/([0-9]+)/answers/(finished|unfinished|unpaid|unjudged)} do |id,filtr|
  @researcher = Researcher[id]
  @pagetitle = "#{filtr} answers for #{@researcher.name}"
  @answers = @researcher.send("answers_#{filtr}")
  @question_for_answers = Question.for_these(@answers)
  erb :researcher_answers
end

put '/researcher/:id' do
  r = Researcher[params[:id]]
  r.update(just(%w(bio)))
  redirect '/researcher/%d' % r.id
end

get '/researchers' do
  @pagetitle = 'researchers'
  @books_researchers = {}
  Book.order(:id).each do |b|
    @books_researchers[b] = b.researchers
  end
  erb :researchers
end

get '/editors' do
  @pagetitle = 'editors'
  @editors = Editor.order(:id).all
  erb :editors
end

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

get '/book/:id/customers' do
  @book = Book[params[:id]]
  @pagetitle = 'customers of ' + @book.short_title
  @customers = @book.customers
  erb :customers
end

get '/customer/:id' do
  @customer = Customer[params[:id]]
  @pagetitle = 'customer: ' + @customer.name
  @books = @customer.books
  @books_to_add = Book.order(:title).all - @books
  @person_url = WoodEgg.config['person_url'] % @customer.person_id
  @sent = params[:sent]
  erb :customer
end

post '/customer/:id/books' do
  c = Customer[params[:id]]
  has_books = c.books
  if params[:book_id] == 'all'
    Book.all.each do |b|
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

post '/customer/:id/email' do
  c = Customer[params[:id]]
  opts = {}
  unless params[:subject].empty?
    opts[:subject] = params[:subject]
  end
  unless params[:message].empty?
    opts[:message] = params[:message]
  end
  c.email_first(opts)
  redirect '/customer/%d?sent=sent' % c.id
end

