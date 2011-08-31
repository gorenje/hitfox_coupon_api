require 'cgi'
require 'digest/sha1'
require 'json'

module HitfoxCouponApi
  class Coupon
    def initialize(product, code)
      @product, @code = product, code
    end

    def used
      config    = HitfoxCouponApi.configuration
      timestamp = config.generate_timestamp
      headers   = {
        "X-API-TOKEN"     => config.api_token,
        "X-API-APP-ID"    => @product.identifier,
        "X-API-TIMESTAMP" => timestamp,
      }

      str = [ @code, config.api_token, timestamp, @product.identifier,
              config.api_secret ].join(",")

      path = "/%s/coupon/%s/used.json?hash=%s" % [CGI.escape(config.api_version.to_s),
                                                  CGI.escape(@code),
                                                  CGI.escape(Digest::SHA1.hexdigest(str))]

      JSON.parse(RestClient.get("%s%s" % [config.api_endpoint, path], headers))
    end
  end
end
