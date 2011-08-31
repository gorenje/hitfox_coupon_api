module HitfoxCouponApi
  class Configuration
    attr_accessor :api_endpoint, :api_token, :api_secret, :api_version

    def initialize
      @api_version = "1"
    end

    def generate_timestamp
      Time.now.strftime("%s")
    end
  end
end
