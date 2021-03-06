require 'rest-client'

require 'hitfox_coupon_api/configuration'
require 'hitfox_coupon_api/client'
require 'hitfox_coupon_api/application'
require 'hitfox_coupon_api/coupon'
require 'hitfox_coupon_api/order'
require 'hitfox_coupon_api/user'

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

  def application(identifier)
    Application.new(identifier)
  end
end
