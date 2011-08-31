module HitfoxCouponApi
  class Product
    attr_reader :identifier

    def initialize(identifier)
      @identifier = identifier
    end

    def coupon(code)
      Coupon.new(self, code)
    end
  end
end
