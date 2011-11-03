module HitfoxCouponApi
  class Order < Client
    attr_accessor :order_id

    def initialize(application, order_id)
      @application, @order_id = application, order_id
    end

    def reserve(count = 1)
      config, headers = configuration, apiheaders

      hshstr = [@order_id, config.api_token, headers["X-API-TIMESTAMP"],
                @application.identifier, config.api_secret].join(",")

      params = [config.api_version.to_s, @order_id, Digest::SHA1.hexdigest(hshstr), count.to_s]
      urlstr = generate_url('/%s/coupon/%s/reserve.json?hash=%s&count=%s', params)

      handle_coupon_results(JSON.parse(RestClient.get(urlstr, headers)))
    end
  end
end
