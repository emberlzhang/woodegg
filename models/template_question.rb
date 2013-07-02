class TemplateQuestion < Sequel::Model(:woodegg__template_questions)
  many_to_one :subtopic
  one_to_many :questions
end
