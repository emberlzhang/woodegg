# encoding: utf-8
class Essay < Sequel::Model(WoodEgg::DB)
  many_to_one :writer
  many_to_one :question
  many_to_one :book

  class << self
    def unjudged
      filter(payable: nil).exclude(finished_at: nil).order(:id).all
    end

    def unfinished
      filter(finished_at: nil).order(:id).all
    end

    def for_country(cc)
      filter(question_id: Question.filter(country: cc.upcase).map(&:id)).order(:question_id).all
    end

    # hash of country_code => howmany_essays
    def country_howmany
      h = {}
      join(:questions, id: :question_id).group_and_count(:country).order(:count.desc).all.each {|e| h[e.values[:country]] = e.values[:count]}
      return h
    end

    def howmany_unedited
      filter(edited_at: nil).exclude(finished_at: nil).count
    end

    def next_unedited_for(editor_id)
      filter(edited_at: nil, editor_id: editor_id).order(:question_id).first
    end

    def next_unedited
      filter(edited_at: nil, editor_id: nil).exclude(finished_at: nil).order(:question_id).first
    end
  end 

  def finished?
    !finished_at.nil?
  end

  def country
    question.country
  end

  def editors
    book.editors
  end

  def subtopic
    question.subtopic
  end

  def topic
    question.topic
  end

end
