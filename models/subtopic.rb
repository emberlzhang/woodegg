class Subtopic < Sequel::Model(WoodEgg::DB)
  many_to_one :topic
  one_to_many :template_questions, :order => :id

  def questions_for_country(country)
    Question.for_subtopic_and_country(self.id, country)
  end

  def questions
    qs = []
    template_questions.each {|t| t.questions.each {|q| qs << q }}
    qs.sort_by(&:id)
  end

end
