class TemplateQuestion < Sequel::Model(WoodEgg::DB)
  many_to_one :subtopic
  one_to_many :questions, :order => :id
end
