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

    def howmany_uncleaned
      filter(cleaned_at: nil).count
    end

    def next_uncleaned_for(email)
      filter(cleaned_at: nil, cleaned_by: email).order(:question_id).first
    end

    def next_uncleaned
      filter(cleaned_at: nil, cleaned_by: nil).exclude(finished_at: nil).order(:question_id).first
    end
  end 

  def finished?
    !finished_at.nil?
  end

  def country
    question.country
  end

end
