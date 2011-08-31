require 'rest-client'

require 'hitfox_coupon_api/configuration'
require 'hitfox_coupon_api/product'
require 'hitfox_coupon_api/coupon'

module HitfoxCouponApi
  extend self

  def configuration
    @configuration ||= Configuration.new
  end

  def configure
    config = configuration
    block_given? ? yield(config) : config
    config
  end
end
