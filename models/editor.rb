class Editor < Sequel::Model(:woodegg__editors)
  many_to_one :person
  many_to_many :books
  include Persony
end
