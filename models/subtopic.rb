class Subtopic < Sequel::Model(:woodegg__subtopics)
  many_to_one :topic
  one_to_many :template_questions

  class << self
    ## four-level subquery!
    # SELECT * FROM subtopics WHERE id IN
    # (SELECT subtopic_id FROM template_questions WHERE id IN 
    # (SELECT template_question_id FROM questions WHERE country='KH' AND id NOT IN 
    # (SELECT question_id FROM answers WHERE payable IS TRUE GROUP BY question_id HAVING COUNT(*) > 2)));
    def available_for_country_dataset(country)
      undone = Question.select(:template_question_id).filter(country: country).exclude(id: Question.completed_ids)
      filter(id: TemplateQuestion.select(:subtopic_id).filter(id: undone))
    end

    def available_for_country(country)
      available_for_country_dataset(country).all
    end

    def available_for_country_and_topic(country, topic_id)
      available_for_country_dataset(country).filter(topic_id: topic_id).all
    end
  end
  
  def questions_for_country(country)
    Question.for_subtopic_and_country(self.id, country)
  end
end
