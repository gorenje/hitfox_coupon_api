module HitfoxCouponApi
  class User < Client
    attr_accessor :user_id

    def initialize(application, user_id)
      @application, @user_id = application, user_id
    end

    def buy_coupon(count = 1)
      config, headers = configuration, apiheaders

      hshstr = [@user_id, config.api_token, headers["X-API-TIMESTAMP"],
                @application.identifier, config.api_secret].join(",")

      params = [config.api_version.to_s, @user_id, Digest::SHA1.hexdigest(hshstr), count.to_s]
      urlstr = generate_url('/%s/coupon/%s/buy.json?hash=%s&count=%s', params)

      handle_coupon_results(JSON.parse(RestClient.get(urlstr, headers)))
    end
  end
end
