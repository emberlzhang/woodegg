class Book < Sequel::Model(WoodEgg::DB)
  one_to_many :essays
  many_to_many :writers
  many_to_many :researchers
  many_to_many :customers

  class << self
    def available
      Book.where('id <= 16').order(:id).all
    end

    def done
      #Book.order(:title).all.select {|b| b.done?}
      Book.where('id <= 16').order(:id).all
    end

    def not_done
      #Book.order(:title).all.reject {|b| b.done?}
      Book.where('id > 16').order(:id).all
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
      h[f] = '%s.%s' % [short_title.gsub(' ', ''), f]
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

  private

    def questions_missing_essays_dataset
      WoodEgg::DB["SELECT questions.id FROM questions LEFT JOIN essays ON questions.id=essays.question_id WHERE questions.country='%s' AND essays.id IS NULL" % country]
    end
end
