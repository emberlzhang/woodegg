class Editor < Sequel::Model(WoodEgg::DB)
  many_to_one :person
  many_to_many :books, :order => :id
  include Persony

  # essays
  # questions
  # answers
  # essays_unedited
  # essays_edited
end
