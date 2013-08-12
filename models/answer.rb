class Answer < Sequel::Model(WoodEgg::DB)
  many_to_one :question
  many_to_one :researcher

  class << self
    def unjudged_dataset
      filter(payable: nil).exclude(finished_at: nil).order(:id)
    end

    def unjudged
      unjudged_dataset.all
    end

    def unjudged_count
      unjudged_dataset.count
    end

    def unjudged_next
      unjudged_dataset.first
    end

    def unfinished_dataset
      filter(finished_at: nil).order(:id)
    end

    def unfinished
      unfinished_dataset.all
    end

    def unfinished_count
      unfinished_dataset.count
    end

    def unfinished_next
      unfinished_dataset.first
    end

    def count_per_country_hash
      h = {}
      WoodEgg::DB['SELECT questions.country, COUNT(answers.id) FROM questions LEFT JOIN answers ON questions.id=answers.question_id GROUP BY questions.country ORDER BY COUNT(answers.id) DESC'].map(&:values).each {|p| h[p[0]] = p[1]}	# converts from array pairs to one hash
      return h
    end
  end

  def essays
    question.essays
  end

  def subtopic
    question.subtopic
  end

  def topic
    question.topic
  end

  def books
    question.books
  end

  def finished?
    !finished_at.nil?
  end

end
