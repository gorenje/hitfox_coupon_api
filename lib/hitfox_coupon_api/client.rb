module HitfoxCouponApi
  class Client
    HitfoxApiException = Class.new(RuntimeError)

    def apiheaders
      config = HitfoxCouponApi.configuration
      {
        "X-API-TOKEN"     => config.api_token,
        "X-API-APP-ID"    => @application.identifier,
        "X-API-TIMESTAMP" => config.generate_timestamp,
      }
    end

    def generate_url(path, params)
      '%s%s' % [HitfoxCouponApi.configuration.api_endpoint, path % params.map { |a| CGI.escape(a) }]
    end
  end
end
