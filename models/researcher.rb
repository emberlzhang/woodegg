class Researcher < Sequel::Model(WoodEgg::DB)
  many_to_one :person
  one_to_many :answers, :order => :id
  many_to_many :books, :order => :id
  include Persony

  class << self
    # experiment to save SQL queries. maybe load this into Persony some day, if useful.
    # returns same as Researcher.all but with name & email pre-loaded
    def all_people
      ol = self.all
      pp = Person.select(:id, :email, :name).filter(id: ol.map(&:person_id)).all
      ol.each do |o|
	p = pp.find {|x| x[:id] == o.person_id}
	o.define_singleton_method(:name) { p.name }
	o.define_singleton_method(:email) { p.email }
	o.values[:name] = p.name
	o.values[:email] = p.email
      end
      ol
    end
  end

  def countries
    books.map(&:country)
  end

  def topics_unfinished
    Topic.filter(id: Subtopic.filter(id: TemplateQuestion.filter(id: Question.filter(country: countries.pop.upcase).exclude(id: answers.map(&:question_id)).map(:template_question_id)).map(:subtopic_id)).map(:topic_id)).order(:id).all
  end

  def questions_answered
    Question.order(:id).filter(id: answers_dataset.select(:question_id).exclude(finished_at: nil)).all
  end

  def answers_finished_count
    answers_dataset.exclude(finished_at: nil).count
  end

  def answers_finished
    answers_dataset.exclude(finished_at: nil).order(:finished_at.desc).all
  end

  def answers_unfinished_count
    answers_dataset.filter(finished_at: nil).count
  end

  def answers_unfinished
    answers_dataset.filter(finished_at: nil).order(:id).all
  end

  def answers_unpaid_count
    answers_dataset.exclude(finished_at: nil).filter(payable: true).count
  end

  def answers_unpaid
    answers_dataset.exclude(finished_at: nil).filter(payable: true).order(:id).all
  end

  def answers_unjudged_count
    answers_dataset.exclude(finished_at: nil).filter(payable: nil).count
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
