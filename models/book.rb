class Book < Sequel::Model(WoodEgg::DB)
  one_to_many :essays, :order => :id
  many_to_many :writers, :order => :id
  many_to_many :researchers, :order => :id
  many_to_many :editors, :order => :id
  many_to_many :customers, :order => :id

  class << self
    def available
      Book.exclude(asin: nil).order(:id).all.select {|b| b.done?}
    end

    def done
      Book.order(:id).all.select {|b| b.done?}
    end

    def not_done
      Book.order(:id).all.reject {|b| b.done?}
    end
  end

  def short_title
    title.split(': ')[0]
  end

  def sub_title
    title.split(': ')[1]
  end

  # {'pdf' => 'MongoliaStartupGuide2013.pdf',
  #  'epub' => 'MongoliaStartupGuide2013.epub',
  #  'mobi' => 'MongoliaStartupGuide2013.mobi'}
  def filename_hash
    h = {}
    %w(pdf epub mobi).each do |f|
      h[f] = '%s.%s' % [leanpub, f]
    end
    h
  end

  def download_url(fmt)
    filename = filename_hash[fmt]
    return false if filename.nil?
    require 'aws/s3'
    AWS::S3::DEFAULT_HOST.replace 's3-ap-southeast-1.amazonaws.com'
    AWS::S3::Base.establish_connection!(
      access_key_id: WoodEgg.config['aws_key'],
      secret_access_key: WoodEgg.config['aws_secret'])
    AWS::S3::S3Object.url_for(filename, 'woodegg', :use_ssl => true)
  end

  def questions
    Question.filter(country: country).order(:id).all
  end

  def questions_missing_essays_count
    questions_missing_essays_dataset.count
  end

  def questions_missing_essays
    Question.filter(id: questions_missing_essays_dataset.map(:id)).order(:id).all
  end

  def essays_uncleaned
    essays_dataset.filter(cleaned_at: nil).order(:id)
  end

  def done?
    questions_missing_essays_count == 0 && essays_uncleaned.count == 0
  end

  # pseudo-associations: for now it's ".all", but some day might be limited
  
  def topics
    Topic.order(:id).all
  end

  def subtopics
    Subtopic.order(:id).all
  end

  def template_questions
    TemplateQuestion.order(:id).all
  end

  def answers
    a = []
    questions.each {|q| a.concat(q.answers)}
    a
  end

  private

    def questions_missing_essays_dataset
      WoodEgg::DB["SELECT questions.id FROM questions LEFT JOIN essays ON questions.id=essays.question_id WHERE questions.country='%s' AND essays.id IS NULL ORDER BY questions.id" % country]
    end
end
