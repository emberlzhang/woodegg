class Tidbit < Sequel::Model(:woodegg__tidbits)
  many_to_many :tags
  many_to_many :questions
end
