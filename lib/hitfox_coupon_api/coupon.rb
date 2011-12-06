require 'cgi'
require 'digest/sha1'
require 'json'

module HitfoxCouponApi
  class Coupon < Client
    attr_accessor :code, :url, :state

    def initialize(application, code, url = nil)
      @application, @code, @url = application, code, url
    end

    # Add new coupon codes to an application.
    # Take an array of coupon details and create deal coupons. The array is assumed to be
    # structured as: [type, code, type, code, link, type, code, type, code, ... etc]
    # where type is one of: :actlink (2 args), :ingame (1 arg), :url (1 arg), e.g.
    #    [:actlink, code, link, :ingame, code, :url, link, :ingame, code, ....]
    # would a valid array.
    # The :actlink type takes two further parameters: link and code, while the ingame and
    # url types only take one further argument.
    def add(cpns_code)
      headers, params = build_request_data(cpns_code.count) do |config, headers, hshstr|
        [config.api_version.to_s, Digest::SHA1.hexdigest(hshstr)]
      end
      urlstr = generate_url('/%s/coupons/create.json?hash=%s', params)
      JSON.parse(RestClient.post(urlstr, { :coupons => cpns_code }, headers))
    end

    def add!(cpns_code)
      res = add(cpns_code)
      res["status"] == 0 ? true : raise(HitfoxApiException, "#{res['status']}: #{res['msg']}")
    end


    # Make a coupon as having been used by the end-user. This should be called once
    # the user has entered and reclaimed their coupon. It provides HitFox with the information
    # that the coupon has been used.
    def used
      headers, params = build_request_data(@code) do |config, headers, hshstr|
        [config.api_version.to_s, @code, Digest::SHA1.hexdigest(hshstr)]
      end
      urlstr = generate_url('/%s/coupon/%s/used.json?hash=%s', params)
      JSON.parse(RestClient.get(urlstr, headers))
    end

    def used!
      res = used
      res["status"] == 0 ? true : raise(HitfoxApiException, "#{res['status']}: #{res['msg']}")
    end

    # Provide details on this coupon. The code, download url and the status are provided
    # of the coupon.
    def info
      headers, params = build_request_data(@code) do |config, headers, hshstr|
        [config.api_version.to_s, @code, Digest::SHA1.hexdigest(hshstr)]
      end

      urlstr = generate_url('/%s/coupon/%s/info.json?hash=%s', params)

      handle_coupon_results(JSON.parse(RestClient.get(urlstr, headers))) do |cpn|
        Coupon.new(Application.new(cpn["app_id"]), cpn["code"], cpn["download_url"]).tap do |cc|
          cc.state = cpn["state"]
        end
      end
    end

    # Are there count-number of coupons avaiable for this product. This is not strictly
    # related to a particular coupon, rather this is delegated down from the application
    # to the coupon, Application#available? should be used instead of this method
    # directly.
    def available?(count = 1)
      headers, params = build_request_data(count) do |config, headers, hshstr|
        [config.api_version.to_s, Digest::SHA1.hexdigest(hshstr), count.to_s]
      end
      urlstr = generate_url('/%s/coupons/available.json?hash=%s&count=%s', params)
      JSON.parse(RestClient.get(urlstr, headers))["status"] == 0
    end

    def app_id
      @application.identifier
    end

    protected

    def build_request_data(hsh_param, &block)
      config, headers = configuration, apiheaders
      hshstr = [ hsh_param, config.api_token, headers["X-API-TIMESTAMP"],
                 @application.identifier, config.api_secret ].join(",")
      [headers, yield(config, headers, hshstr)]
    end
  end
end
