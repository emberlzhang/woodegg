#encoding: utf-8
require 'kramdown'

class WoodEggDotCom < Oth

  def pagetitle(title)
    @pagetitle = title
    @pagetitle += ' | Wood Egg' unless @pagetitle.include? 'Wood Egg'
  end

  configure do
    # set root one level up, since this routes file is inside subdirectory
    set :root, File.dirname(File.dirname(File.realpath(__FILE__)))
    set :views, Proc.new { File.join(root, 'views/woodegg.com') }
  end

  before do
    @countrylist = Countries.hsh.values.join(', ')
  end

  not_found do
    redirect '/', 301
  end

  get '/' do
    @bodyid = 'homepage'
    pagetitle 'Entrepreneur’s Guides to Asia'
    @countries = Countries.hsh
    @cc_title = {}
    Book.select(:country, :title).all.each {|b| @cc_title[b.country] = b.title}
    erb :home
  end

  get '/about' do
    @bodyid = 'aboutpage'
    pagetitle 'About'
    erb :about
  end

  get '/contact' do
    @bodyid = 'contactpage'
    pagetitle 'Contact'
    erb :contact
  end

  get Regexp.new(Countries.routemap) do |cc|
    @bodyid = 'bookpage'
    @country_code = cc
    @ccode = cc.upcase
    @cname = Countries.hsh[@ccode]
    @country_name = @cname.gsub(' ', '&nbsp;')
    @country_name = 'the&nbsp;Philippines' if @country_name == 'Philippines'
    @book = Book.filter(country: @ccode).first
    @booktitle = @book.title
    @isbn = @book.isbn
    pagetitle @booktitle
    @title, @subtitle = @booktitle.split(': ')
    @questions = File.open("./views/woodegg.com/q-#{cc}.html", 'r:utf-8').read
    @salescopy = Kramdown::Document.new(@book.salescopy).to_html
    erb :bookpage
  end
end
