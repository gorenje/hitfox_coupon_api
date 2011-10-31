require 'cgi'
require 'digest/sha1'
require 'json'

module HitfoxCouponApi
  class Coupon < Client
    attr_accessor :code, :url

    def initialize(product, code, url = nil)
      @application, @code, @url = product, code, url
    end

    def used
      config, headers = HitfoxCouponApi.configuration, apiheaders

      hshstr = [ @code, config.api_token, headers["X-API-TIMESTAMP"],
                 @application.identifier, config.api_secret ].join(",")

      params = [config.api_version.to_s, @code, Digest::SHA1.hexdigest(hshstr)]
      urlstr = generate_url('/%s/coupon/%s/used.json?hash=%s', params)
      JSON.parse(RestClient.get(urlstr, headers))
    end
  end
end
