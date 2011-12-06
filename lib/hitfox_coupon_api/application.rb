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

    # return the true/false if count coupons are available for the application
    def available?(count = 1)
      Coupon.new(self,nil).available?(count)
    end

    # take an array of coupon details and create deal coupons. The array is assumed to be
    # structured as: [type, code, type, code, link, type, code, type, code, ... etc]
    # where type is one of: :actlink (2 args), :ingame (1 arg), :url (1 arg), e.g.
    #    [:actlink, code, link, :ingame, code, :url, link, :ingame, code, ....]
    # would a valid array.
    def add_coupons(cpns_code)
      Coupon.new(self,nil).add(cpns_code)
    end
    def add_coupons!(cpns_code)
      Coupon.new(self,nil).add!(cpns_code)
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
