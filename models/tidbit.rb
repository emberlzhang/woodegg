class Tidbit < Sequel::Model(WoodEgg::DB)
  many_to_many :tags
  many_to_many :questions
end
