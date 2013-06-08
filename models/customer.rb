class Customer < Sequel::Model(WoodEgg::DB)
  many_to_one :person
  many_to_many :books
  include Persony

  def email_first(opts={})
    opts[:baseurl] ||= 'https://woodegg.com/a/'
    opts[:subject] ||= 'your Wood Egg ebook'
    opts[:message] ||= 'I just created you an account on woodegg.com with your free ebook available to download inside. Enjoy!'
    person.email_reset_message(opts)
  end
end
