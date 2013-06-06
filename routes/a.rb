include ERB::Util
require 'kramdown'

class WoodEggA < Oth

  configure do
    # set root one level up, since this routes file is inside subdirectory
    set :root, File.dirname(File.dirname(File.realpath(__FILE__)))
    set :views, Proc.new { File.join(root, 'views/a') }
  end

  before Oth::ROUTEREG do
    oth!
    @customer = @person.customer
  end

  get '/' do
    redirect "#{OTH_MAP}/proof" if @customer.nil?
    @pagetitle = 'account'
    erb :home
  end

  get '/proof' do
    @pagetitle = 'book registration'
    erb :proof
  end

  post '/proof' do
    if params[:book].nil? || Book[code: params[:book]].nil? || params[:proof].nil? || params[:proof].empty?
      redirect "#{OTH_MAP}/proof"
    end
    @person.add_userstat(statkey: 'proof-' + params[:book], statvalue: params[:proof], created_at: Date.today)
    redirect "#{OTH_MAP}/thanks"
  end

  get '/thanks' do
    @pagetitle = 'thank you'
    erb :thanks
  end

  get %r{\A/book/(we1[3-9][a-z]{2})\Z} do |code|
    redirect "#{OTH_MAP}/proof" if @customer.nil?
    @book = Book[code: code]
    redirect "#{OTH_MAP}/" unless @customer.books.include? @book
    @pagetitle = @book.short_title
    erb :book
  end

  #get '/book/:code/questions/:id' do
  get %r{\A/book/(we1[3-9][a-z]{2})/questions/([0-9]+)\Z} do |code, id|
    redirect "#{OTH_MAP}/proof" if @customer.nil?
    @book = Book[code: code]
    redirect "#{OTH_MAP}/" unless @customer.books.include? @book
    @question = @book.questions.find {|b| b[:id] == id.to_i}
    redirect "#{OTH_MAP}/book/#{code}" unless @question
    @pagetitle = @book.short_title + ' QUESTION: ' + @question.question
    @essay = Kramdown::Document.new(@question.essays[0].content).to_html
    erb :book_question
  end

  get '/book/:code/:fmt/:filename' do
    redirect "#{OTH_MAP}/proof" if @customer.nil?
    book = Book[code: params[:code]]
    redirect "#{OTH_MAP}/" unless @customer.books.include? book
    download_url = book.download_url(params[:fmt])
    redirect "#{OTH_MAP}/book/#{params[:code]}" unless download_url
    redirect download_url
  end

end
