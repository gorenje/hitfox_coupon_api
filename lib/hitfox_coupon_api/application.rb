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
  end
end
