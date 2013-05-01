class Question < Sequel::Model(WoodEgg::DB)
  many_to_one :template_question
  one_to_many :answers
  one_to_many :essays

  class << self
    def total_for_country(country)
      filter(country: country).count
    end

    # id => question hash
    def hash_for_country(country)
      h = {}
      select(:id, :question).filter(country: 'ID').order(:id).map(&:values).each {|p| h[p[:id]] = p[:question]}
      h
    end

    def completed_ids  # the usual group_and_count wasn't working for some reason  # HACK - SHOULD BE 2 NOT 3
      WoodEgg::DB['SELECT question_id FROM answers WHERE payable IS TRUE GROUP BY question_id HAVING COUNT(*) > 3'].map(&:values).flatten
    end

    def dataset_for_subtopic_and_country(subtopic, country)
      filter(template_question_id: TemplateQuestion.filter(subtopic_id: subtopic).map(&:id)).filter(country: country).order(:id)
    end

    def for_subtopic_and_country(subtopic, country)
      dataset_for_subtopic_and_country(subtopic, country).all
    end

    def available_for_subtopic_and_country(subtopic, country)
      dataset_for_subtopic_and_country(subtopic, country).exclude(id: completed_ids).all
    end

    def needing_essays_for_country(cc)
      filter(country: cc.upcase).order(:id).exclude(id: Essay.for_country(cc).map(&:question_id)).all
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

    # hash with answer_id as key, question object as value
    # USAGE:
    # @answers = @researcher.answers_unfinished
    # @questions_for_answers = Question.for_answers(@answers)
    # IN VIEW:
    # @answers.each do |a|
    #   <h2>@questions_for_answers[a.id]</h2>
    #   <p>a.answer</p>
    def for_answers(array_of_answers)
      ret = {}
      questions = filter(id: array_of_answers.map(&:question_id)).all
      array_of_answers.each do |a|
	ret[a.id] = questions.select {|q| q[:id] == a.question_id}.pop
      end
      ret
    end

  end
end
