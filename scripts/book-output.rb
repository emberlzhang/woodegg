#!/usr/bin/env ruby
require '../models.rb'
require 'fileutils'

# get country code
unless ARGV[0] && Countries.hsh.keys.include?(ARGV[0].upcase)
  raise "\nUSAGE: ./book-output.rb {country_code}"
end

# create output directories
country_code = ARGV[0].upcase
basedir = "/tmp/we13#{country_code.downcase}"
puts "OUTPUT DIRECTORY: #{basedir}"
Dir.mkdir(basedir) unless File.directory?(basedir)
outdir = basedir + '/manuscript'
Dir.mkdir(outdir) unless File.directory?(outdir)
imgdir = outdir + '/images'
Dir.mkdir(imgdir) unless File.directory?(imgdir)

# get book & initialize array of filenames to be put in Book.txt
book = Book.filter(country: country_code).first
filenames = []

# cover = title_page.jpg = 1650 pixels wide and 2400 pixels high at 300 PPI


# start with chapter00.txt - the intro
chapter = 0
outfile = 'chapter%02d.txt' % chapter
filenames << outfile
File.open(outdir + '/' + outfile, 'w') do |f|
  f.puts book.intro.gsub("\r", '')
end

# go through each topic as a chapter
topicnest = Question.topicnest(book.questions, Question.topichash(country_code))
topicnest.each do |t|
  chapter += 1
  outfile = 'chapter%02d.txt' % chapter
  filenames << outfile
  File.open(outdir + '/' + outfile, 'w') do |f|
    f.puts '# ' + t[0] + "\n\n"
    t[1].each do |subtopic, questions|
      f.puts '## ' + subtopic + "\n\n"
      questions.each do |q|
	f.puts '### ' + q.question + "\n\n"
	f.puts q.essays[0].content.gsub("\r", '') + "\n\n"
      end
    end
  end
end

# final page = credits (+ copy images while at it)
chapter += 1
outfile = 'chapter%02d.txt' % chapter
filenames << outfile
File.open(outdir + '/' + outfile, 'w') do |f|
  f.puts '# CREDITS' + "\n\n"
  f.puts '## Researchers:' + "\n\n"
  book.researchers.each do |r|
    f.puts '### ' + r.name + "\n\n"
    f.puts r.bio + "\n\n"
    photo = 'researcher-%d.jpg' % r.id
    f.puts "![](images/%s)\n\n" % photo
    FileUtils.cp('/srv/public/woodegg/public/images/300/' + photo, imgdir + '/' + photo)
  end
  f.puts '## Editor:' + "\n\n"
  book.editors.each do |r|
    f.puts '### ' + r.name + "\n\n"
    f.puts r.bio + "\n\n"
    photo = 'editor-%d.jpg' % r.id
    f.puts "![](images/%s)\n\n" % photo
    FileUtils.cp('/srv/public/woodegg/public/images/300/' + photo, imgdir + '/' + photo)
  end
  f.puts '## Artwork:' + "\n\n"
  f.puts 'Cover design by Charlie Pabst of CharfishDesign.com'

  f.puts "\n\nAnd lastly, here’s that intro again, to make sure you didn’t miss it:\n\n"
  f.puts book.intro.gsub("\r", '')
end

# index of files, for ebook making:
File.open(outdir + '/Book.txt', 'w') do |f|
  f.puts filenames.join("\n")
end

