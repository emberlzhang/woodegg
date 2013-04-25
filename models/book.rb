class Book < Sequel::Model(WoodEgg::DB)
  one_to_many :essays
  many_to_many :editors
  many_to_many :researchers

  def questions
    Question.filter(country: country).all
  end

  def questions_missing_essays_count
    questions_missing_essays_dataset.count
  end

  def questions_missing_essays
    Question.filter(id: questions_missing_essays_dataset.map(:id)).all
  end

  private

    def questions_missing_essays_dataset
      WoodEgg::DB["SELECT questions.id FROM questions LEFT JOIN essays ON questions.id=essays.question_id WHERE questions.country='MM' AND essays.id IS NULL"]
    end
end
