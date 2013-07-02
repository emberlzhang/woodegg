# encoding: utf-8
class Essay < Sequel::Model(:woodegg__essays)
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

    # hash of: book['Topic1']['SubTopic1']['Question8'] => 'EssayAnswer'
    def book_for(cc)
      book = {}
      Topic.all.each do |t|
        t.subtopics.each do |st|
          Question.for_subtopic_and_country(st.id, cc).each do |q|
            book[t.topic] ||= {}
            book[t.topic][st.subtopic] ||= {}
            book[t.topic][st.subtopic][q.question] = q.essays[0].essay_html
          end
        end
      end
      book
    end

    def html_for(cc, write_chapters = false)
      booktitle = 'Entrepreneur’s Guide to ' + Countries.hsh[cc] + ' 2013'
      t = st = q = nav = 1
      chap = []
      toc = "<h1>Table of Contents</h1>\r\n"
      ncx = '<?xml version="1.0" encoding="utf-8" ?>
<!DOCTYPE ncx PUBLIC "-//NISO//DTD ncx 2005-1//EN" "http://www.daisy.org/z3986/2005/ncx-2005-1.dtd">
<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" xml:lang="en" version="2005-1">
<head>
<meta name="dtb:uid" content="booktitle" />
<meta name="dtb:depth" content="1" />
<meta name="dtb:totalPageCount" content="0" />
<meta name="dtb:maxPageNumber" content="0" />
</head>
<docTitle><text>booktitle</text></docTitle>
<navMap>
<navPoint id="navPoint-1" playOrder="1"><navLabel><text>Table of Contents</text></navLabel><content src="section-0000.html" /></navPoint>
'.gsub('booktitle', booktitle).gsub("\n", "\r\n")
      nav += 1
      head = '<?xml version="1.0" encoding="utf-8" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8" />
<link rel="stylesheet" type="text/css" href="style.css" />
<title></title>
</head>
<body>'.gsub("\n", "\r\n")
      book = book_for(cc)
      book.each do |topic, subtopics|
        chap[t] = ''
        chap[t] << "\r\n<a id=\"topic#{t}\"></a>\r\n"
        chap[t] << "<h1>#{topic}</h1>\r\n"
        toc << ('<h2><a href="section-%04d.html">' % t) + topic + '</a></h2>' + "\r\n"
        ncx << '<navPoint id="navPoint-%d" playOrder="%d"><navLabel><text>%s</text></navLabel><content src="section-%04d.html" /></navPoint>' % [nav, nav, topic, t]
	ncx << "\r\n"
        subtopics.each do |subtopic, questions|
          chap[t] << "\r\n<a id=\"subtopic#{st}\"></a>\r\n"
          chap[t] << "<h2>#{subtopic}</h2>\r\n"
          toc << ('<h3><a href="section-%04d.html#subtopic%d">' % [t, st]) + subtopic + '</a></h3>' + "\r\n<ul>\r\n"
          questions.each do |question, essay_html|
            chap[t] << "\r\n<a id=\"question#{q}\"></a>\r\n"
            chap[t] << "<h3>#{question}</h3>\r\n"
            chap[t] << "#{essay_html}\r\n"
            toc << ('<li><a href="section-%04d.html#question%d">' % [t, q]) + question + '</a></li>' + "\r\n"
            q += 1
          end
          toc << "</ul>\r\n"
          st += 1
        end
        if write_chapters
          File.open('/tmp/epub/OPS/section-%04d.html' % t, 'w') do |f|
            f.puts(head.gsub('<title></title>', '<title>' + topic + '</title>') + chap[t] + '</body></html>')
          end
        end
        t += 1
        nav += 1
      end
      ncx << '</navMap></ncx>'
      if write_chapters
        File.open('/tmp/epub/OPS/section-0000.html', 'w') do |f|
          f.puts(head.gsub('<title></title>', '<title>Table of Contents</title>') + toc + '</body></html>')
        end
	File.open('/tmp/epub/OPS/toc.ncx', 'w') {|f| f.puts ncx }
      end
      chap[0] = toc
      return (head.gsub('<title></title>', "<title>#{booktitle}</title>") + chap.join("\r\n") + '</body></html>')
    end

  end # end class << self

  def finished?
    !finished_at.nil?
  end

  def country
    question.country
  end

  # ugly pseudo-markdown
  def essay_html
    require 'erb'
    html = ''
    in_p = false
    in_ul = false
    in_ol = false
    content.split("\n").each do |line|
      line.strip!
      line = ERB::Util.html_escape line
      if line[0,2] == '* '
        if in_ul
          html << "</ul>\r\n"
          in_ul = false
        end
        if in_ol
          html << "</ol>\r\n"
          in_ol = false
        end
        if in_p
          html << "</p>\r\n"
          in_p = false
        end
        line = ('<h4>' + line[2..-1] + '</h4>')
      elsif line[0,2] == '- '
        line = ('<li>' + line[2..-1] + '</li>')
        if in_p
          html << "</p>\r\n"
          in_p = false
        end
        unless in_ul
          html << "<ul>\r\n"
          in_ul = true
        end
      elsif line[0,2] == '# '
        line = ('<li>' + line[2..-1] + '</li>')
        if in_p
          html << "</p>\r\n"
          in_p = false
        end
        unless in_ol
          html << "<ol>\r\n"
          in_ol = true
        end
      elsif line == ''
        if in_ul
          html << "</ul>\r\n"
          in_ul = false
        end
        if in_ol
          html << "</ol>\r\n"
          in_ol = false
        end
        if in_p
          html << "</p>\r\n"
          in_p = false
        end
        next
      else
        line = (line[0...-1] + '<br />') if line[-1,1] == '\\'
        unless in_p
          html << "<p>\r\n"
          in_p = true
        end
      end
      html << "#{line}\r\n" if(line.size > 0)
    end
    if in_ul
      html << "</ul>\r\n"
      in_ul = false
    end
    if in_ol
      html << "</ol>\r\n"
      in_ol = false
    end
    if in_p
      html << "</p>\r\n"
      in_p = false
    end
    return html
  end
end
