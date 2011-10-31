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
  end
end
