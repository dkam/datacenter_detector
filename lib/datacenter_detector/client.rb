module DatacenterDetector
  class Client
    def initialize(dbf: nil)
      @cache = Cache.new(dbf: dbf)
    end

    def query(ip:, force: false)
      response = @cache.get(ip: ip, force: force)
      
      if response.nil?
        response = DatacenterDetector.query(ip)
        @cache.add(response.result) if response.status.to_s == "200"
      end
    
      return response
  
    end
  end
end