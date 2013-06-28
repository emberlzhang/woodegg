ENV['testing'] = 'test'
require 'test/unit'
require_relative '../models.rb'

class TestResearcher < Test::Unit::TestCase
  include Fixtures::Tools
end

class TestWriter < Test::Unit::TestCase
  include Fixtures::Tools
end

class TestCustomer < Test::Unit::TestCase
  include Fixtures::Tools
end

class TestEditor < Test::Unit::TestCase
  include Fixtures::Tools
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

