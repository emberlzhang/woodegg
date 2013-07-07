class Question < Sequel::Model(WoodEgg::DB)
  many_to_one :template_question
  one_to_many :answers, :order => :id
  one_to_many :essays, :order => :id
  many_to_many :tidbits, :order => :id

  class << self
    def total_for_country(country)
      filter(country: country).count
    end

    # id => question hash
    def hash_for_country(country)
      h = {}
      select(:id, :question).filter(country: country).order(:id).map(&:values).each {|p| h[p[:id]] = p[:question]}
      h
    end

    def for_subtopic_and_country(subtopic, country)
      filter(template_question_id: TemplateQuestion.filter(subtopic_id: subtopic).map(&:id)).filter(country: country).order(:id).all
    end

    # returns hash where key = Question.id, value = {topic: "the topic", subtopic: "the subtopic"}
    def topichash(cc)
      h = {}
      WoodEgg::DB["SELECT questions.id, topics.topic, subtopics.subtopic FROM questions JOIN template_questions ON questions.template_question_id=template_questions.id JOIN subtopics ON template_questions.subtopic_id=subtopics.id JOIN topics ON subtopics.topic_id=topics.id WHERE questions.country='#{cc.upcase}' ORDER BY topics.id ASC, subtopics.id ASC, questions.id ASC"].each {|x| h[x.delete(:id)] = x}
      h
    end

    # returns hash {topic => {subtopic => [array, of, question, objects]}}
    def topicnest(questions, topichash)
      h = {}
      questions.each do |q|
	tst = topichash[q.id]
	h[tst[:topic]] ||= {}
	h[tst[:topic]][tst[:subtopic]] ||= []
	h[tst[:topic]][tst[:subtopic]] << q
      end
      h
    end

    # hash with id as key, question object as value
    # Works for answers or essays.
    # USAGE:
    # @answers = @researcher.answers_unfinished
    # @questions_for_answers = Question.for_these(@answers)
    # IN VIEW:
    # @answers.each do |a|
    #   <h2>@questions_for_answers[a.id]</h2>
    #   <p>a.answer</p>
    def for_these(ary)
      ret = {}
      questions = filter(id: ary.map(&:question_id)).all
      ary.each do |x|
	ret[x.id] = questions.select {|q| q[:id] == x.question_id}.pop
      end
      ret
    end

  end

  def books
    Book.where(country: country).order(:id).all
  end

  def subtopic
    template_question.subtopic
  end

  def topic
    template_question.subtopic.topic
  end

  def researchers
    rs = []
    answers.each {|a| rs << a.researcher unless rs.include? a.researcher}
    rs
  end

  def editors
    eds = []
    books.each {|b| b.editors.each {|e| eds << e unless eds.include? e}}
    eds
  end
end
