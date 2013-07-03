class Tidbit < Sequel::Model(WoodEgg::DB)
  many_to_many :tags, :order => :name
  many_to_many :questions, :order => :id
end
