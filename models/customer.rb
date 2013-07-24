class Customer < Sequel::Model(WoodEgg::DB)
  many_to_one :person
  many_to_many :books, :order => :id
  include Persony

  def email_first
    f = Formletter[WoodEgg.config['formletter_created_acct'].to_i]
    p = self.person
    h = {subject: 'your Wood Egg ebook', category: 'woodegg', profile: 'derek@sivers'}
    f.send_to(p, h)
  end

  def email_post_proof(book)
    f = Formletter[WoodEgg.config['formletter_thanks_buying'].to_i]
    p = self.person
    p.define_singleton_method(:booktitle) { book.short_title }
    h = {subject: 'Thank you for buying the ' + book.short_title, category: 'woodegg', profile: 'derek@sivers'}
    f.send_to(p, h)
  end

end
