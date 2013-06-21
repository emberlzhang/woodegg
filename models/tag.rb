class Tag < Sequel::Model(WoodEgg::DB)
  many_to_many :tidbits
end
