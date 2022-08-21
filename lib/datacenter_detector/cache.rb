require "sqlite3"
module DatacenterDetector
  class Cache
    attr_accessor :hit_count, :miss_count

    def initialize(dbf: Cache.default_database_file)
      @hit_count = 0
      @miss_count = 0
      @db = SQLite3::Database.new dbf || Cache.default_database_file
      @db.busy_timeout = 100
      setup_range
      setup_range6
      setup_agents
      setup_cache_counter
    end

    def hitrate
      hit = get_counter('hit')
      miss = get_counter('miss')

      hit / (hit + miss).to_f
    end

    def hit!
      increment('hit')
    end

    def miss!
      increment('miss')
    end

    def increment(counter)
      @db.transaction do |d|
        d.execute(
          "UPDATE cache_counter SET value=value + 1 WHERE name=?", counter
        )
      end
    end

    def get_counter(counter)
      return @db.execute( "select value from cache_counter where name = ?", counter )&.first&.first
    end

    def add(result)
      result = result.result if result.respond_to?(:result)
      cidr = result.cidr || result.asn&.cidr
      return if cidr.nil?
      network = IPAddr.new(cidr)

      if network.ipv6?
        table  = "ranges6"
        start  = network.to_range.first.to_i.to_s(16)
        finish = network.to_range.last.to_i.to_s(16)
      else
        table  = "ranges"
        start  = network.to_range.first.to_i
        finish = network.to_range.last.to_i
      end

      result_hash = DatacenterDetector.to_hash(result)

      record = [cidr, start, finish, result.is_datacenter ? 1 : 0,
                result.server || result.datacenter || result.asn&.descr, result_hash.to_json]

      @db.transaction do |d|
        d.execute(
          "INSERT INTO #{table} (cidr, start, finish, is_datacenter, name, response, retreived_at, created_at)  VALUES (?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)", record
        )
      end
    rescue IPAddr::AddressFamilyError => e
      puts "Exception #{e.inspect}"
      puts "CIDR: #{cidr}"
      puts "Result: #{result}"
    end

    def get(ip:, force: false)
      return nil if force

      a = IPAddr.new(ip)
      resp = if a.ipv6?
               @db.execute(
                 "select cidr, name, is_datacenter, retreived_at, created_at, response from ranges6 where start <= ? and finish >= ?", [
                   a.to_i.to_s(16), a.to_i.to_s(16)
                 ]
               ).first
             else
               @db.execute(
                 "select cidr, name, is_datacenter, retreived_at, created_at, response from ranges where start <= ? and finish >= ?", [
                   a.to_i, a.to_i
                 ]
               ).first
             end

      miss! and return nil if resp.nil?
      hit!

      resp = { cidr: resp[0], name: resp[1], is_datacenter: (resp[2] == 1), retreived_at: resp[3], created_at: resp[4],
               result: resp[5], status: 301 }

      DatacenterDetector.to_ostruct(resp)
    rescue StandardError => e
      puts "Exception finding ip: #{ip}"
      puts e.message
      []
    end

    def setup_range
      return unless @db.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='ranges'").length == 0

      @db.execute("CREATE TABLE ranges(cidr TEXT, start INTEGER, finish INTEGER, is_datacenter BOOLEAN, name TEXT, country TEXT, retreived_at timestamp, response TEXT, created_at timestamp CURRENT_TIMESTAMP, UNIQUE(cidr) on conflict replace, UNIQUE(start, finish) ON CONFLICT REPLACE);")
      @db.execute("CREATE INDEX 'idx_start'   ON ranges ( 'start' );")
      @db.execute("CREATE INDEX 'idx_finish'  ON ranges ( 'finish' );")
      @db.execute("CREATE INDEX 'idx_isdc' ON ranges ( 'is_datacenter' );")
    end

    def setup_range6
      return unless @db.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='ranges6'").length == 0

      @db.execute("CREATE TABLE ranges6(cidr TEXT, start INTEGER, finish INTEGER, is_datacenter BOOLEAN, name TEXT, country TEXT, retreived_at timestamp, response TEXT, created_at timestamp CURRENT_TIMESTAMP, UNIQUE(cidr) on conflict replace, UNIQUE(start, finish) ON CONFLICT REPLACE);")
      @db.execute("CREATE INDEX 'idx_start6'   ON ranges6 ( 'start' );")
      @db.execute("CREATE INDEX 'idx_finish6'  ON ranges6 ( 'finish' );")
      @db.execute("CREATE INDEX 'idx_isdc6' ON ranges6 ( 'is_datacenter' );")
    end

    def setup_agents
      return unless @db.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='agents'").length == 0

      @db.execute("CREATE TABLE agents(name VARCHAR, full  VARCHAR, quality INTEGER);")
      @db.execute("CREATE UNIQUE INDEX 'uniq_name'  ON agents ( 'name' );")
      @db.execute("CREATE INDEX 'idx_agent_quality' ON agents ( 'quality' );")
    end

    def setup_cache_counter
      return unless @db.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='cache_counter'").length == 0

      @db.execute("CREATE TABLE cache_counter(name VARCHAR, value INTEGER);")
      @db.execute("INSERT INTO cache_counter (name, value)  VALUES ('hit', 0)")
      @db.execute("INSERT INTO cache_counter (name, value)  VALUES ('miss', 0)")
    rescue SQLite3::SQLException => e
      puts "Exception creating cache_counter: #{e.inspect}"
    end

    def self.default_database_file
      if defined?(Rails.root)
        File.join(Rails.root, "db", "datacenter_detector.db")
      else
        File.join(File.expand_path("~"), ".datacenter_detector.db")
      end
    end
  end
end
