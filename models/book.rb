class Book < Sequel::Model(WoodEgg::DB)
  one_to_many :essays
  many_to_many :editors
  many_to_many :researchers

  class << self
    def done
      Book.order(:title).all.select {|b| b.done?}
    end

    def not_done
      Book.order(:title).all.reject {|b| b.done?}
    end
  end

  def questions
    Question.filter(country: country).order(:id).all
  end

  def questions_missing_essays_count
    questions_missing_essays_dataset.count
  end

  def questions_missing_essays
    Question.filter(id: questions_missing_essays_dataset.map(:id)).order(:id).all
  end

  def essays_uncleaned
    essays_dataset.filter(cleaned_at: nil).order(:id)
  end

  def done?
    questions_missing_essays_count == 0 && essays_uncleaned.count == 0
  end

  private

    def questions_missing_essays_dataset
      WoodEgg::DB["SELECT questions.id FROM questions LEFT JOIN essays ON questions.id=essays.question_id WHERE questions.country='%s' AND essays.id IS NULL" % country]
    end
end
