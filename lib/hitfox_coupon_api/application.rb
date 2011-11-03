module HitfoxCouponApi
  class Application
    attr_reader :identifier

    def initialize(identifier)
      @identifier = identifier
    end

    def coupon(code)
      Coupon.new(self, code)
    end

    def user(user_id)
      User.new(self, user_id)
    end

    def order(order_id)
      Order.new(self, order_id)
    end

    # Allow an application to have a specific configuration. This allows
    # one company to manage multiple products.
    def configuration
      @configuration
    end

    def configure
      @configuration ||= HitfoxCouponApi.configuration.dup
      block_given? ? yield(@configuration) : @configuration
      @configuration
    end
  end
end
