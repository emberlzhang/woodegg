class Answer < Sequel::Model(WoodEgg::DB)
  many_to_one :question
  many_to_one :person

  class << self
    def unjudged
      filter(payable: nil).exclude(finished_at: nil).order(:id).all
    end

    def unfinished
      filter(finished_at: nil).order(:id).all
    end

    def count_per_country_hash
      h = {}
      WoodEgg::DB['SELECT questions.country, COUNT(answers.id) FROM questions LEFT JOIN answers ON questions.id=answers.question_id GROUP BY questions.country ORDER BY COUNT(answers.id) DESC'].map(&:values).each {|p| h[p[0]] = p[1]}	# converts from array pairs to one hash
      return h
    end
  end

  def finished?
    !finished_at.nil?
  end
end
