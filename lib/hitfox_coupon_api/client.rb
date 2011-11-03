module HitfoxCouponApi
  class Client
    HitfoxApiException = Class.new(RuntimeError)

    def configuration
      @application.configuration || HitfoxCouponApi.configuration
    end

    def apiheaders
      config = configuration
      {
        "X-API-TOKEN"     => config.api_token,
        "X-API-APP-ID"    => @application.identifier,
        "X-API-TIMESTAMP" => config.generate_timestamp,
      }
    end

    def generate_url(path, params)
      '%s%s' % [configuration.api_endpoint, path % params.map { |a| CGI.escape(a) }]
    end

    def handle_coupon_results(res)
      if res["status"] == 0
        res["coupons"].map { |c| c[c.keys.first] }.map do |cc|
          Coupon.new(@application, cc["code"], cc["download_url"])
        end
      else
        raise HitfoxApiException, "#{res['status']}: #{res['msg']}"
      end
    end
  end
end
