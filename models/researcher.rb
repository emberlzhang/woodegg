class Researcher < Sequel::Model(WoodEgg::DB)
  many_to_one :person
  one_to_many :answers, :order => :id
  many_to_many :books, :order => :id
  one_to_many :uploads, :order => :id
  include Persony

  class << self
    def without_books
      sql = "SELECT researchers.id FROM researchers" +
      " LEFT JOIN books_researchers ON researchers.id=books_researchers.researcher_id" +
      " WHERE books_researchers.book_id IS NULL"
      r_ids = WoodEgg::DB[sql].map {|x| x[:id]}
      Researcher.where(id: r_ids).order(:id).all
    end

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

    # TODO: researchers.active boolean flag?
    def active
      r_ids = WoodEgg::DB['SELECT DISTINCT researcher_id FROM books_researchers WHERE book_id > 16'].map(&:values).flatten
      Researcher.where(id: r_ids).order(:id).all
    end
  end

  def countries
    books.map(&:country)
  end

  def topics_unfinished
    topics = []
    questions_unanswered.each do |q|
      topics << q.topic unless topics.include? q.topic
    end
    topics
  end

  def subtopics_unfinished_in_topic(topic_id)
    subtopics = []
    questions_unanswered.each do |q|
      subtopics << q.subtopic unless subtopics.include? q.subtopic
    end
    subtopics.select {|s| s.topic_id == topic_id}
  end
  
  def questions_unfinished_in_subtopic(subtopic_id)
    questions_unanswered.select {|q| q.subtopic.id == subtopic_id}
  end
  
  def questions
    q = []
    books.each {|b| q.concat(b.questions)}
    q
  end

  def questions_answered
    Question.order(:id).filter(id: answers_dataset.select(:question_id).exclude(finished_at: nil)).all
  end

  def questions_unanswered
    questions - questions_answered
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
