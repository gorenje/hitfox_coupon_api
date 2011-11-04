require 'cgi'
require 'digest/sha1'
require 'json'

module HitfoxCouponApi
  class Coupon < Client
    attr_accessor :code, :url, :state

    def initialize(application, code, url = nil)
      @application, @code, @url = application, code, url
    end

    def add(cpns_code)
      config, headers = configuration, apiheaders

      hshstr = [ cpns_code.count, config.api_token, headers["X-API-TIMESTAMP"],
                 @application.identifier, config.api_secret ].join(",")

      params = [config.api_version.to_s, Digest::SHA1.hexdigest(hshstr)]
      urlstr = generate_url('/%s/coupons/create.json?hash=%s', params)
      JSON.parse(RestClient.post(urlstr, { :coupons => cpns_code }, headers))
    end

    def add!(cpns_code)
      res = add(cpns_code)
      res["status"] == 0 ? true : raise(HitfoxApiException, "#{res['status']}: #{res['msg']}")
    end

    def used
      config, headers = configuration, apiheaders

      hshstr = [ @code, config.api_token, headers["X-API-TIMESTAMP"],
                 @application.identifier, config.api_secret ].join(",")

      params = [config.api_version.to_s, @code, Digest::SHA1.hexdigest(hshstr)]
      urlstr = generate_url('/%s/coupon/%s/used.json?hash=%s', params)
      JSON.parse(RestClient.get(urlstr, headers))
    end

    def used!
      res = used
      res["status"] == 0 ? true : raise(HitfoxApiException, "#{res['status']}: #{res['msg']}")
    end

    def info
      config, headers = configuration, apiheaders

      hshstr = [ @code, config.api_token, headers["X-API-TIMESTAMP"],
                 @application.identifier, config.api_secret ].join(",")

      params = [config.api_version.to_s, @code, Digest::SHA1.hexdigest(hshstr)]
      urlstr = generate_url('/%s/coupon/%s/info.json?hash=%s', params)

      handle_coupon_results(JSON.parse(RestClient.get(urlstr, headers))) do |cpn|
        Coupon.new(Application.new(cpn["app_id"]), cpn["code"], cpn["download_url"]).tap do |cc|
          cc.state = cpn["state"]
        end
      end
    end

    def app_id
      @application.identifier
    end
  end
end
