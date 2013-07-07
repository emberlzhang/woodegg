class TemplateQuestion < Sequel::Model(WoodEgg::DB)
  many_to_one :subtopic
  one_to_many :questions, :order => :id

  def topic
    subtopic.topic
  end

  def answers
    as = []
    questions.each {|q| q.answers.each {|a| as << a if a.finished_at }}
    as.sort_by(&:id)
  end

  def essays
    es = []
    questions.each {|q| q.essays.each {|e| es << e if e.finished_at }}
    es.sort_by(&:id)
  end

end
