module HitfoxCouponApi
  class Order < Client
    attr_accessor :order_id

    def initialize(application, order_id)
      @application, @order_id = application, order_id
    end

    # Reserve count coupons for an order. These are reserved for a specific application,
    # if an order contains multiple products/deals/applications, then this needs to called
    # once for each.
    def reserve(count = 1)
      headers, params = build_request_data
      urlstr = generate_url('/%s/coupon/%s/reserve.json?hash=%s&count=%s', params + [count.to_s])
      handle_coupon_results(JSON.parse(RestClient.get(urlstr, headers)))
    end

    # Make as paid the coupons attached to the order. Once again, this is related only to
    # those coupons that are from this application. If an order contains coupons from an
    # application, then they need to be marked paid separately.
    def paid
      headers, params = build_request_data
      urlstr = generate_url('/%s/coupon/%s/paid.json?hash=%s', params)
      handle_coupon_results(JSON.parse(RestClient.get(urlstr, headers)))
    end

    # Return a list of coupons of this order. Once again, this will only provide a list of
    # coupons that are attached to this application.
    def coupons
      headers, params = build_request_data
      urlstr = generate_url('/%s/coupon/%s/list.json?hash=%s', params)
      handle_coupon_results(JSON.parse(RestClient.get(urlstr, headers)))
    end

    protected

    def build_request_data
      config, headers = configuration, apiheaders

      hshstr = [@order_id, config.api_token, headers["X-API-TIMESTAMP"],
                @application.identifier, config.api_secret].join(",")

      params = [config.api_version.to_s, @order_id, Digest::SHA1.hexdigest(hshstr)]
      [headers, params]
    end
  end
end
