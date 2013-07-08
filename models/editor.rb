class Editor < Sequel::Model(WoodEgg::DB)
  many_to_one :person
  many_to_many :books, :order => :id
  include Persony

  def essays_unedited
    es = []
    books.each {|b| b.essays.each {|e| es << e if (e.finished_at && e.edited_at.nil?)}}
    es
  end

  def essays_edited
    es = []
    books.each {|b| b.essays.each {|e| es << e if e.edited_at }}
    es
  end
 
  def questions_unedited
    qs = []
    books.each {|b| b.essays.each {|e| qs << e.question if (e.finished_at && e.edited_at.nil?)}}
    qs
  end

  def questions_edited
    qs = []
    books.each {|b| b.essays.each {|e| qs << e.question if e.edited_at }}
    qs
  end

end
