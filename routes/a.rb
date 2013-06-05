include ERB::Util

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

  get '/book/:code' do
    redirect "#{OTH_MAP}/proof" if @customer.nil?
    @book = Book[code: params[:code]]
    redirect "#{OTH_MAP}/" unless @customer.books.include? @book
    @pagetitle = @book.short_title
    erb :book
  end

  get '/book/:code/questions' do
    redirect "#{OTH_MAP}/proof" if @customer.nil?
    @book = Book[code: params[:code]]
    redirect "#{OTH_MAP}/" unless @customer.books.include? @book
    @pagetitle = @book.short_title + ' QUESTIONS'
    erb :book_questions
  end

end
