class Tag < Sequel::Model(:woodegg__tags)
  many_to_many :tidbits
end
