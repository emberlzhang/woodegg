class Editor < Sequel::Model(WoodEgg::DB)
  many_to_one :person
  many_to_many :books
  include Persony
end
