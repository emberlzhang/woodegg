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

  # need to require 'mailconfig.rb' with smtp settings. give Book object
  def email_post_proof(book)
    email_address = self.person.email
    email_subject = 'Thank you for buying the ' + book.short_title
    email_body = "Hi #{self.person.firstname} -\n\n#{email_subject}.\n\nI just registered it in your Wood Egg account now, so please go to https://woodegg.com/a/ and you'll see you have full access to all the original research from the book.  Some day I'll get all other resources and materials available in here, too.\n\nANY questions at all, please just email me anytime.  Thanks!\n\n"
    email_body += "--\nDerek Sivers  derek@sivers.org  http://sivers.org/\n"
    Mail.deliver do
      from 'Derek Sivers <derek@sivers.org>'
      to email_address
      subject email_subject
      body email_body
    end
  end

end
