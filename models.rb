# encoding: utf-8
require 'peeps'

class WoodEgg
  @dbase = 'woodegg'
  @fbase = __FILE__
  extend DatabaseInfo
end

class NilClass
  def h ; '' ; end
  def to_html ; '' ; end
  def size ; 0 ; end
end

class String
  def h
    self.encode(self.encoding, :xml => :attr)[1...-1]
  end

  def nl2br
    self.gsub("\n", '<br/>')
  end

  def autolink
    self.gsub(/(http\S*)/, '<a href="\1">\1</a>')
  end

  def to_html
    self.h.nl2br.autolink
  end
end

class Person
  one_to_one :editor
  one_to_one :researcher

  # hardcoded to just me and MR for now. some day could make admins table.
  def admin?
    [1, 59196].include?(id)
  end

  # in people.userstats for now. some day could make cleaners table.
  def cleaner?
    (userstats_dataset.filter(:statkey => 'woodegg', :statvalue => 'cleaner').first).nil? ? false : true
  end
end

class Countries
  class << self
    def hsh
      {'KH' => 'Cambodia',
      'CN' => 'China',
      'HK' => 'Hong Kong',
      'IN' => 'India',
      'ID' => 'Indonesia',
      'JP' => 'Japan',
      'KR' => 'Korea',
      'MY' => 'Malaysia',
      'MN' => 'Mongolia',
      'MM' => 'Myanmar',
      'PH' => 'Philippines',
      'SG' => 'Singapore',
      'LK' => 'Sri Lanka',
      'TW' => 'Taiwan',
      'TH' => 'Thailand',
      'VN' => 'Vietnam'}
    end

    def codes
      hsh.keys
    end

    # helper for routes like /cn or /jp
    def routemap
      '/(' + codes.map(&:downcase).join('|') + ')$'
    end

    # helper for routes like /cn/123 or /tw/321
    def routemap2
      '/(' + codes.map(&:downcase).join('|') + ')/(\d*)$'
    end
  end
end

