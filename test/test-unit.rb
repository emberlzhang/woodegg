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

