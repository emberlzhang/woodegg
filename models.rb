require 'peeps'
require 'yaml'

class WoodEgg
  @dbase = 'woodegg'
  @fbase = __FILE__
  @config = nil
  extend DatabaseInfo

  def self.config
    if @config.nil?
      @config = YAML.load_file(File.dirname(@fbase) + '/config.yml')
    end
    @config
  end
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
  one_to_one :customer

  # hardcoded to just me, Karol,and MR for now.
  def admin?
    [1, 10471, 59196].include?(id)
  end

  # in people.userstats for now. some day could make cleaners table.
  def cleaner?
    (userstats_dataset.filter(:statkey => 'woodegg', :statvalue => 'cleaner').first).nil? ? false : true
  end
end

# for Rack::Auth::Basic to share info with Sinatra routes (instead of @@person)
class HTTPAuth
  @person = nil
  class << self
    attr_accessor :person
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
      '/(' + codes.map(&:downcase).join('|') + ')/([0-9]+)$'
    end

    # how many of each roles for each country 
    # {'ANY' => {'writer' => 19, 'researcher' => 32'}, 'KH' => {'writer' => 3}}
    def hiring_count
      roles = %w(editor writer researcher)
      statkeys = "'woodegg','" + Countries.hsh.keys.map {|x| "woodegg-#{x.downcase}"}.join("','") + "'"
      statvalues = "'" + roles.join("','") + "'"
      query = "SELECT statkey, statvalue, COUNT(*) FROM userstats" +
	" WHERE statkey IN (#{statkeys}) AND statvalue IN (#{statvalues})" +
	" GROUP BY statkey, statvalue ORDER BY statkey, statvalue"
      # init the empty grid
      hh = {} ; roles.each {|x| hh[x] = 0}
      grid = {'ANY' => hh.dup}
      hsh.keys.each {|c| grid[c] = hh.dup}
      Sequel.postgres('peeps', user: 'peeps').fetch(query) do |row|
	if row[:statkey] == 'woodegg'
	  c = 'ANY'
	else
	  /woodegg-(\w{2})/ =~ row[:statkey]
	  c = $1.upcase
	end
	grid[c][row[:statvalue]] = row[:count]
      end
      grid
    end
  end
end

