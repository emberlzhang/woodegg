class Answer < Sequel::Model(:woodegg__answers)
  many_to_one :question
  many_to_one :researcher

  class << self
    def unjudged
      filter(payable: nil).exclude(finished_at: nil).order(:id).all
    end

    def unfinished
      filter(finished_at: nil).order(:id).all
    end

    def count_per_country_hash
      h = {}
      WoodEgg::DB['SELECT woodegg.questions.country, COUNT(woodegg.answers.id) FROM woodegg.questions LEFT JOIN woodegg.answers ON woodegg.questions.id=woodegg.answers.question_id GROUP BY woodegg.questions.country ORDER BY COUNT(woodegg.answers.id) DESC'].map(&:values).each {|p| h[p[0]] = p[1]}	# converts from array pairs to one hash
      return h
    end
  end

  def finished?
    !finished_at.nil?
  end
end
