class Editor < Sequel::Model(WoodEgg::DB)
  many_to_one :person
  many_to_many :books, :order => :id
  include Persony

  class << self
    def without_books
      sql = "SELECT editors.id FROM editors" +
      " LEFT JOIN books_editors ON editors.id=books_editors.editor_id" +
      " WHERE books_editors.book_id IS NULL"
      r_ids = WoodEgg::DB[sql].map {|x| x[:id]}
      Editor.where(id: r_ids).order(:id).all
    end
  end

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
