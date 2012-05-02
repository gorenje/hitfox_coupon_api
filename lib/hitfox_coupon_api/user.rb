module HitfoxCouponApi
  class User < Client
    attr_accessor :user_id

    def initialize(application, user_id)
      @application, @user_id = application, user_id
    end

    # buy count coupons for this application. If there aren't enough coupons, then this
    # will return an empty list. This is an all-or-nothing call, if count coupons aren't
    # available, then none are bought.
    def buy_coupon(count = 1)
      headers, params = build_request_data
      urlstr = generate_url('/%s/coupon/%s/buy.json?hash=%s&count=%s', params + [count.to_s])
      handle_coupon_results(JSON.parse(RestClient.get(urlstr, headers)))
    end

    # Get a list coupons for this user, for this application.
    def coupons
      headers, params = build_request_data
      urlstr = generate_url('/%s/coupon/%s/show.json?hash=%s', params)
      handle_coupon_results(JSON.parse(RestClient.get(urlstr, headers)))
    end

    protected

    def build_request_data
      config, headers = configuration, apiheaders

      hshstr = [@user_id, config.api_token, headers["X-API-TIMESTAMP"],
                @application.identifier, config.api_secret].join(",")

      params = [config.api_version.to_s, @user_id, Digest::SHA1.hexdigest(hshstr)]
      [headers, params]
    end
  end
end
