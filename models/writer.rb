class Writer < Sequel::Model(WoodEgg::DB)
  many_to_one :person
  one_to_many :essays, :order => :id
  many_to_many :books, :order => :id
  include Persony

  def countries
    books.map(&:country)
  end

  def essays_finished_count
    essays_dataset.exclude(finished_at: nil).count
  end

  def essays_finished
    essays_dataset.exclude(finished_at: nil).order(:finished_at.desc).all
  end

  def essays_unfinished_count
    essays_dataset.filter(finished_at: nil).count
  end

  def essays_unfinished
    essays_dataset.filter(finished_at: nil).order(:id).all
  end

  def essays_unjudged_count
    essays_dataset.exclude(finished_at: nil).filter(payable: nil).count
  end

  def essays_unjudged
    essays_dataset.exclude(finished_at: nil).filter(payable: nil).order(:id).all
  end

  def approve_finished_unjudged_essays
    essays_dataset.exclude(finished_at: nil).filter(payable: nil).update(payable: true)
  end

  def essays_unpaid_count
    essays_dataset.exclude(finished_at: nil).filter(payable: true).count
  end

  def essays_unpaid
    essays_dataset.exclude(finished_at: nil).filter(payable: true).order(:id).all
  end

  def question_ids_essayed
    essays.map(&:question_id)
  end

  def howmany_unessayed
    Question.total_for_country(countries.pop) - essays_dataset.count
  end

  def essay_topics_unfinished
    Topic.filter(id: Subtopic.filter(id: TemplateQuestion.filter(id: Question.filter(country: countries.pop).exclude(id: essays.map(&:question_id)).map(:template_question_id)).map(:subtopic_id)).map(:topic_id)).order(:id).all
  end
end
