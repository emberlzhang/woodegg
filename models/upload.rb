class Upload < Sequel::Model(WoodEgg::DB)
  many_to_one :researcher
  FILEDIR = '/srv/http/uploads/'

  class << self
    # NOTE: dataset, not results
    def missing_info
      filter(transcription: nil).or(transcription: '').or(notes: nil).or(notes: '').order(:id)
    end

    # NOTE: results, not dataset
    def missing_info_for(researcher_id)
      missing_info.filter(researcher_id: researcher_id).all
    end

    def post_from_researcher(researcher_id, filefield, notes)
      info = {researcher_id: researcher_id,
	notes: notes,
	mime_type: filefield[:type],
	their_filename: filefield[:filename],
        our_filename: our_filename_for(researcher_id, filefield[:filename])}
      fullpath = FILEDIR + info[:our_filename]
      File.open(fullpath, 'w') do |f|
        f.write(filefield[:tempfile].read)
      end
      info[:bytes] = FileTest.size(fullpath)
      m = /\s(\d:\d{2}:\d{2})\s/.match `exiftool #{fullpath} | grep ^Duration`
      if m
	info[:duration] = m[1]
      end
      create(info)
    end

    def our_filename_for(researcher_id, their_filename)
      'r%03d-%s-%s' % [
	researcher_id,
	Time.now.strftime('%Y%m%d'),
	their_filename.downcase.gsub(/[^a-z0-9._-]/, '')]
    end

    def sync_next
      u = find(uploaded: 'n')
      return false if u.nil?
      u.update(uploaded: 'p')
      require 'aws/s3'
      AWS::S3::DEFAULT_HOST.replace 's3-ap-southeast-1.amazonaws.com'
      AWS::S3::Base.establish_connection!(
	access_key_id: WoodEgg.config['aws_key'],
	secret_access_key: WoodEgg.config['aws_secret'])
      AWS::S3::S3Object.store(u.our_filename,
	open(FILEDIR + u.our_filename),
	'woodegg',
	{:access => :public_read, :content_type => u.mime_type})
      u.update(uploaded: 'y')
    end
  end

  def url
    'http://woodegg.s3.amazonaws.com/' + our_filename
  end

  def uploaded_status
    case uploaded
    when 'n' then 'not uploaded (wait 10 minutes)'
    when 'p' then 'currently uploading (wait 1 minute)'
    when 'y' then 'uploaded'
    end
  end

  def missing_info?
    (String(transcription) == '' || String(notes) == '')
  end

end
