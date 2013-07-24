class Customer < Sequel::Model(WoodEgg::DB)
  many_to_one :person
  many_to_many :books, :order => :id
  include Persony

  def email_first(opts={})
    opts[:baseurl] ||= 'https://woodegg.com/a/'
    opts[:subject] ||= 'your Wood Egg ebook'
    opts[:message] ||= 'I just created you an account on woodegg.com with your free ebook available to download inside. Enjoy!'
    person.email_reset_message(opts)
  end

  def email_post_proof(book)
    f = Formletter[WoodEgg.config['formletter_thanks_buying']]
    p = self.person
    p.define_singleton_method(:booktitle) { book.short_title }
    h = {subject: 'Thank you for buying the ' + book.short_title, category: 'woodegg', profile: 'derek@sivers'}
    f.send_to(p, h)
  end

end
