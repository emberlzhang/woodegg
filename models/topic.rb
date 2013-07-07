class Topic < Sequel::Model(WoodEgg::DB)
  one_to_many :subtopics, :order => :id
  class << self
    def shuffle
      all.shuffle
    end
  end

  def template_questions
    qs = []
    subtopics.each {|s| s.template_questions.each {|t| qs << t }}
    qs
  end

  def questions
    qs = []
    subtopics.each {|s| s.questions.each {|q| qs << q }}
    qs.sort_by(&:id)
  end

end
