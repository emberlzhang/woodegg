class Upload < Sequel::Model(WoodEgg::DB)
  many_to_one :researcher
  FILEDIR = '/srv/http/uploads/'

  class << self
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
      create(info)
    end

    def our_filename_for(researcher_id, their_filename)
      'r%03d-%s-%s' % [
	researcher_id,
	Time.now.strftime('%Y%m%d%H%m'),
	their_filename.downcase.gsub(/[^a-z0-9._-]/, '')
      ]
    end
  end

end
