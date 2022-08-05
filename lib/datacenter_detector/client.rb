module DatacenterDetector
  class Client
    attr_reader :cache
    def initialize(dbf: nil)
      @cache = Cache.new(dbf: dbf)
    end

    def hitrate
      @cache.hitrate
    end

    def query(ip:, force: false)
      response = @cache.get(ip: ip, force: force)

      if response.nil?
        response = DatacenterDetector.query(ip)
        @cache.add(response.result) if response.status.to_s == "200"
      end

      response
    end
  end
end
