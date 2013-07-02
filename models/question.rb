class Question < Sequel::Model(:woodegg__questions)
  many_to_one :template_question
  one_to_many :answers
  one_to_many :essays
  many_to_many :tidbits

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
      WoodEgg::DB['SELECT question_id FROM woodegg.answers WHERE payable IS TRUE GROUP BY question_id HAVING COUNT(*) > 3'].map(&:values).flatten
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
      WoodEgg::DB["SELECT woodegg.questions.id, woodegg.topics.topic, woodegg.subtopics.subtopic FROM woodegg.questions JOIN woodegg.template_questions ON woodegg.questions.template_question_id=woodegg.template_questions.id JOIN woodegg.subtopics ON woodegg.template_questions.subtopic_id=woodegg.subtopics.id JOIN woodegg.topics ON woodegg.subtopics.topic_id=woodegg.topics.id WHERE woodegg.questions.country='#{cc.upcase}' ORDER BY woodegg.topics.id ASC, woodegg.subtopics.id ASC, woodegg.questions.id ASC"].each {|x| h[x.delete(:id)] = x}
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
end
