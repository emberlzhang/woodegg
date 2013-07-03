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
    assert_equal x.name, @fixtures['Person']['oompa']['name']
    assert_equal x.email, @fixtures['Person']['oompa']['email']
    x = Customer[2]
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

  def test_associations
    x = Book[1]
    assert_equal 2, x.topics.size
    assert_equal 'Country', x.topics[0].topic
    assert_equal 4, x.subtopics.size
    assert_equal 'how big', x.subtopics[0].subtopic
    assert_equal 5, x.template_questions.size
    assert_equal 'how big is {COUNTRY}?', x.template_questions[0].question
    assert_equal [6,7,8,9,10], x.questions.map(&:id)
    assert x.questions.map(&:question).all? {|q| q.include? 'China'}
    assert_equal [1,2,3,4,5], x.answers.map(&:id)
    assert x.answers.map(&:answer).all? {|q| q.include? 'China'}
    assert_equal [1,2,3,4,5], x.essays.map(&:id)
    assert x.essays.map(&:content).all? {|q| q.include? 'China'}
    assert_equal [Researcher[1]], x.researchers
    assert_equal [Writer[1]], x.writers
    assert_equal [Editor[1]], x.editors
    assert_equal [Customer[1], Customer[2]], x.customers
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

