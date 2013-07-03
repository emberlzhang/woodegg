class Topic < Sequel::Model(WoodEgg::DB)
  one_to_many :subtopics, :order => :id
  class << self
    def shuffle
      all.shuffle
    end

    def available_for_country(country)
      filter(id: Subtopic.available_for_country(country).map(&:topic_id).uniq).all
    end
  end
end
