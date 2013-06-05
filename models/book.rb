class Book < Sequel::Model(WoodEgg::DB)
  one_to_many :essays
  many_to_many :editors
  many_to_many :researchers
  many_to_many :customers

  class << self
    def done
      Book.order(:title).all.select {|b| b.done?}
    end

    def not_done
      Book.order(:title).all.reject {|b| b.done?}
    end
  end

  def short_title
    title.split(': ')[0]
  end

  def sub_title
    title.split(': ')[1]
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

  # TODO: a nested list of questions for this book
  # {"Topic Here" => [
  #   {"Subtopic Here" => [{123 => "Question here"}, {124 => "Another question"}], 
  #    "Another Subtopic" => [{125 => "Yet Another"}, {126 => "And Another"}]},
  #   {"Subtopic Four" => [{127 => "Question here"}, {128 => "Another question"}], 
  #    "Another Subtopic" => [{129 => "Yet Another"}, {130 => "And Another"}]}
  # ], "Topic Two" => [etc]}
  #

  private

    def questions_missing_essays_dataset
      WoodEgg::DB["SELECT questions.id FROM questions LEFT JOIN essays ON questions.id=essays.question_id WHERE questions.country='%s' AND essays.id IS NULL" % country]
    end
end
