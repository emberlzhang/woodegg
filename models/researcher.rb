class Researcher < Sequel::Model(WoodEgg::DB)
  many_to_one :person
  one_to_many :answers
  many_to_many :books
  include Persony

  def countries
    books.map(&:country)
  end

  def topics_unfinished
    Topic.filter(id: Subtopic.filter(id: TemplateQuestion.filter(id: Question.filter(country: countries.pop.upcase).exclude(id: answers.map(&:question_id)).map(:template_question_id)).map(:subtopic_id)).map(:topic_id)).order(:id).all
  end

  def answers_finished
    answers_dataset.exclude(finished_at: nil).order(:finished_at.desc).all
  end

  def answers_unfinished
    answers_dataset.filter(finished_at: nil).order(:id).all
  end

  def answers_unpaid
    answers_dataset.exclude(finished_at: nil).filter(payable: true).order(:id).all
  end

  def answers_unjudged
    answers_dataset.exclude(finished_at: nil).filter(payable: nil).order(:id).all
  end

  def question_ids_answered
    answers.map(&:question_id)
  end

  def howmany_unassigned
    Question.total_for_country(countries.pop.upcase) - answers_dataset.count
  end

end
