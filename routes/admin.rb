require 'sinatra'
root = File.dirname(File.dirname(File.realpath(__FILE__)))
require "#{root}/models.rb"

configure do
  set :root, root
  set :views, Proc.new { File.join(root, 'views/admin') }
end

class HTTPAuth
  @person = nil
  class << self
    attr_accessor :person
  end
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
  @pagetitle = 'admin home'
  @books_done = Book.done
  @books_not_done = Book.not_done
  erb :home
end

get '/book/:id' do
  @book = Book[params[:id]]
  @pagetitle = @book.title
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
  b.update(just(%w(country title isbn)))
  redirect '/book/%d' % b.id
end

get '/book/:id/questions' do
  @book = Book[params[:id]]
  @pagetitle = @book.title + ' questions'
  @questions = @book.questions
  erb :questions
end

get '/book/:id/essays' do
  @book = Book[params[:id]]
  @pagetitle = @book.title + ' essays'
  @essays = @book.essays
  # pre-load question for each essay into hash
  questions = @book.questions
  @question_for_essay = {}
  @essays.each do |e|
    @question_for_essay[e.id] = questions.select {|q| q[:id] == e.question_id}.pop
  end
  erb :essays
end
