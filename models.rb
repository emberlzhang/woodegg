# encoding: utf-8
require 'peeps'

class WoodEgg
  @dbase = 'woodegg'
  @fbase = __FILE__
  extend DatabaseInfo
end

class NilClass
  def h ; '' ; end
  def to_html ; '' ; end
  def size ; 0 ; end
end

class String
  def h
    self.encode(self.encoding, :xml => :attr)[1...-1]
  end

  def nl2br
    self.gsub("\n", '<br/>')
  end

  def autolink
    self.gsub(/(http\S*)/, '<a href="\1">\1</a>')
  end

  def to_html
    self.h.nl2br.autolink
  end
end

class Person
  one_to_one :editor
  one_to_one :researcher
end

class Person  # re-opening
  one_to_many :answers
  one_to_many :essays

  class << self
    def researchers
      person_ids = Userstat.filter(statkey: 'woodegg-qa').map(&:person_id)
      Person.filter(id: person_ids).order(:name).all
    end

    def editors
      person_ids = Userstat.filter(statkey: 'woodegg-ed').map(&:person_id)
      Person.filter(id: person_ids).order(:name).all
    end
  end

  def is_admin?
    [1, 59196].include?(id)
  end

  def woodegg_qa_countries
    userstats_dataset.filter(statkey: 'woodegg-qa').map(&:statvalue)
  end

  def woodegg_ed_countries
    userstats_dataset.filter(statkey: 'woodegg-ed').map(&:statvalue)
  end

  def answers_finished
    answers_dataset.exclude(finished_at: nil).order(:finished_at.desc).all
  end

  def essays_finished
    essays_dataset.exclude(finished_at: nil).order(:finished_at.desc).all
  end

  def answers_unfinished
    answers_dataset.filter(finished_at: nil).order(:id).all
  end

  def essays_unfinished
    essays_dataset.filter(finished_at: nil).order(:id).all
  end

  def answers_unjudged
    answers_dataset.exclude(finished_at: nil).filter(payable: nil).order(:id).all
  end

  def essays_unjudged
    essays_dataset.exclude(finished_at: nil).filter(payable: nil).order(:id).all
  end

  def answers_unpaid
    answers_dataset.exclude(finished_at: nil).filter(payable: true).order(:id).all
  end

  def essays_unpaid
    essays_dataset.exclude(finished_at: nil).filter(payable: true).order(:id).all
  end

  def question_ids_answered
    answers.map(&:question_id)
  end

  def question_ids_essayed
    essays.map(&:question_id)
  end

  def howmany_unassigned
    Question.total_for_country(woodegg_qa_countries.pop.upcase) - answers.count
  end

  def howmany_unessayed
    Question.total_for_country(woodegg_ed_countries.pop.upcase) - essays.count
  end

  def topics_unfinished
    Topic.filter(id: Subtopic.filter(id: TemplateQuestion.filter(id: Question.filter(country: woodegg_qa_countries.pop.upcase).exclude(id: answers.map(&:question_id)).map(:template_question_id)).map(:subtopic_id)).map(:topic_id)).order(:id).all
  end

  def essay_topics_unfinished
    Topic.filter(id: Subtopic.filter(id: TemplateQuestion.filter(id: Question.filter(country: woodegg_qa_countries.pop.upcase).exclude(id: essays.map(&:question_id)).map(:template_question_id)).map(:subtopic_id)).map(:topic_id)).order(:id).all
  end

  def cleaner?
    (userstats_dataset.filter(:statkey => 'woodegg', :statvalue => 'cleaner').first).nil? ? false : true
  end
end

class Countries
  class << self
    def hsh
      {'KH' => 'Cambodia',
      'CN' => 'China',
      'HK' => 'Hong Kong',
      'IN' => 'India',
      'ID' => 'Indonesia',
      'JP' => 'Japan',
      'KR' => 'Korea',
      'MY' => 'Malaysia',
      'MN' => 'Mongolia',
      'MM' => 'Myanmar',
      'PH' => 'Philippines',
      'SG' => 'Singapore',
      'LK' => 'Sri Lanka',
      'TW' => 'Taiwan',
      'TH' => 'Thailand',
      'VN' => 'Vietnam'}
    end

    def codes
      hsh.keys
    end

    # TODO : put these somewhere better
    def routemap
      '/(' + codes.map(&:downcase).join('|') + ')$'
    end

    def routemap2
      '/(' + codes.map(&:downcase).join('|') + ')/(\d*)$'
    end
  end
end

