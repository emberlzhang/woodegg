ENV['testing'] = 'test'
require 'test/unit'
require_relative '../models.rb'

class TestResearcher < Test::Unit::TestCase
  include Fixtures::Tools

  def test_researcher
    x = Researcher[1]
    assert_equal x.name, @fixtures['Person']['gongli']['name']
    assert_equal x.email, @fixtures['Person']['gongli']['email']
    x = Researcher[2]
    assert_equal x.name, @fixtures['Person']['yoko']['name']
    assert_equal x.email, @fixtures['Person']['yoko']['email']
    x = Researcher[3]
    assert_equal x.name, @fixtures['Person']['oompa']['name']
    assert_equal x.email, @fixtures['Person']['oompa']['email']
    rap = Researcher.all_people
    assert_equal 3, rap.count
    assert_equal({:id=>2, :person_id=>8, :bio=>'Yes I am Yoko Ono', :name=>'Yoko Ono', :email=>'yoko@ono.com'}, rap[1].values)
  end

  def test_researcher_assocations
    assert_equal [6,7,8,9], Researcher[2].answers.map(&:id)
    assert_equal [], Researcher[3].answers
    assert_equal [Book[3]], Researcher[3].books
    assert_equal [], Researcher[1].topics_unfinished
    assert_equal [Topic[2]], Researcher[2].topics_unfinished
    assert_equal [Topic[1],Topic[2]], Researcher[3].topics_unfinished
    assert_equal 5, Researcher[1].answers_finished_count
    assert_equal [5,4,3,2,1], Researcher[1].answers_finished.map(&:id)
    assert_equal 3, Researcher[2].answers_finished_count
    assert_equal [8,7,6], Researcher[2].answers_finished.map(&:id)
    assert_equal 0, Researcher[3].answers_finished_count
    assert_equal [], Researcher[3].answers_finished
    assert_equal [1,2,3,4,5], Researcher[1].questions_answered.map(&:id)
    assert_equal [6,7,8], Researcher[2].questions_answered.map(&:id)
    assert_equal [], Researcher[3].questions_answered
    assert_equal Book[3].questions, Researcher[3].questions
    assert_equal [], Researcher[1].questions_unanswered
    assert_equal [Question[9],Question[10]], Researcher[2].questions_unanswered
    assert_equal [1,2,3,4,5], Researcher[3].questions_unanswered.map(&:id)
    assert_equal [Answer[9]], Researcher[2].answers_unfinished
    assert_equal [], Researcher[3].answers_unfinished
    assert_equal [Answer[6],Answer[7]], Researcher[2].answers_unpaid
    assert_equal [Answer[4],Answer[5]], Researcher[1].answers_unjudged
    assert_equal [6,7,8,9], Researcher[2].question_ids_answered
    assert_equal [], Researcher[3].question_ids_answered
    assert_equal 0, Researcher[1].howmany_unassigned
    assert_equal 1, Researcher[2].howmany_unassigned
    assert_equal 5, Researcher[3].howmany_unassigned
  end

  def test_new_researcher
    r = Researcher.create(person_id: 6)
    r.add_book(Book[2])
    assert_equal 5, r.howmany_unassigned
    assert_equal [6,7,8,9,10], r.questions_unanswered.map(&:id)
  end
end

class TestWriter < Test::Unit::TestCase
  include Fixtures::Tools

  def test_writer
    x = Writer[1]
    assert_equal x.name, @fixtures['Person']['veruca']['name']
    assert_equal x.email, @fixtures['Person']['veruca']['email']
    x = Writer[2]
    assert_equal x.name, @fixtures['Person']['charlie']['name']
    assert_equal x.email, @fixtures['Person']['charlie']['email']
  end
end

class TestCustomer < Test::Unit::TestCase
  include Fixtures::Tools

  def test_customer
    x = Customer[1]
    assert_equal x.name, @fixtures['Person']['augustus']['name']
    assert_equal x.email, @fixtures['Person']['augustus']['email']
  end
end

class TestEditor < Test::Unit::TestCase
  include Fixtures::Tools

  def test_editor
    x = Editor[1]
    assert_equal x.name, @fixtures['Person']['derek']['name']
    assert_equal x.email, @fixtures['Person']['derek']['email']
    x = Editor[2]
    assert_equal x.name, @fixtures['Person']['wonka']['name']
    assert_equal x.email, @fixtures['Person']['wonka']['email']
  end
end

class TestTopic < Test::Unit::TestCase
  include Fixtures::Tools
end

class TestSubtopic < Test::Unit::TestCase
  include Fixtures::Tools
end

class TestTemplateQuestion < Test::Unit::TestCase
  include Fixtures::Tools
end

class TestQuestion < Test::Unit::TestCase
  include Fixtures::Tools
end

class TestAnswer < Test::Unit::TestCase
  include Fixtures::Tools
end

class TestBook < Test::Unit::TestCase
  include Fixtures::Tools

  def test_book
    x = Book[1]
    assert_equal 'China 2013: How To', x.title
    assert_equal 'China 2013', x.short_title
    assert_equal 'How To', x.sub_title
    assert_equal({'pdf' => 'ChinaStartupGuide2013.pdf', 'epub' => 'ChinaStartupGuide2013.epub', 'mobi' => 'ChinaStartupGuide2013.mobi'}, x.filename_hash)
  end

  def test_download_url
    # https://s3-ap-southeast-1.amazonaws.com/woodegg/ChinaStartupGuide2013.pdf?AWSAccessKeyId=BLAHBLAHBLAH&Expires=1372837301&Signature=bLaHbLaH
    x = Book[1]
    u = x.download_url('pdf')
    assert_match /^https:\/\//, u
    assert u.include? 'ChinaStartupGuide2013.pdf'
    assert_match /AWSAccessKeyId=[A-Z0-9]{20}&/, u
    assert_match /Expires=\d+&/, u
    assert_match /Signature=\S+\Z/, u
  end

  def test_book_associations
    x = Book[1]
    assert_equal 2, x.topics.size
    assert_equal 'Country', x.topics[0].topic
    assert_equal 4, x.subtopics.size
    assert_equal 'how big', x.subtopics[0].subtopic
    assert_equal 5, x.template_questions.size
    assert_equal 'how big is {COUNTRY}?', x.template_questions[0].question
    assert_equal [1,2,3,4,5], x.questions.map(&:id)
    assert x.questions.map(&:question).all? {|q| q.include? 'China'}
    assert_equal [1,2,3,4,5], x.answers.map(&:id)
    assert x.answers.map(&:answer).all? {|q| q.include? 'China'}
    assert_equal [1,2,3,4,5], x.essays.map(&:id)
    assert x.essays.map(&:content).all? {|q| q.include? 'China'}
    assert_equal [Researcher[1]], x.researchers
    assert_equal [Writer[1]], x.writers
    assert_equal [Editor[1]], x.editors
    assert_equal [Customer[1]], x.customers
    x = Book[3]
    assert_equal [1,2,3,4,5], x.questions.map(&:id)
    assert_equal [1,2,3,4,5], x.answers.map(&:id)
    assert_equal [], x.essays
  end

  def test_books
    assert_equal [Book[1],Book[2],Book[3]], Book.order(:id).all
    assert_equal [Book[1]], Book.available
    assert_equal [Book[1]], Book.done
    assert_equal [Book[2],Book[3]], Book.not_done
    assert Book[1].done?
    refute Book[2].done?
    refute Book[3].done?
  end

  def test_books_missing
    assert_equal [], Book[1].questions_missing_essays
    assert_equal 0, Book[1].questions_missing_essays_count
    assert_equal [Question[9], Question[10]], Book[2].questions_missing_essays
    assert_equal 2, Book[2].questions_missing_essays_count
    assert_equal [], Book[1].essays_uncleaned.all
    assert_equal 1, Book[2].essays_uncleaned.count
    assert_equal [Essay[7]], Book[2].essays_uncleaned.all
  end

end

class TestEssay < Test::Unit::TestCase
  include Fixtures::Tools
end

class TestTag < Test::Unit::TestCase
  include Fixtures::Tools
end

class TestTidbit < Test::Unit::TestCase
  include Fixtures::Tools
end

