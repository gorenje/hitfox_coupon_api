require File.dirname(__FILE__)+'/helper'

class TestHitfoxCouponApi < Test::Unit::TestCase
  context "coupon used" do
    setup do
      HitfoxCouponApi.configure do |c|
        c.api_token = "1234"
        c.api_secret = "2143abce"
        c.api_version = "one"
        c.api_endpoint = "http://banana.com"
      end
    end

    should "generate the correct hash value" do
      url = ("http://banana.com/one/coupon/abcdedfg-1234-jakl/used.json?"+
             "hash=97c68554af339f1017155b1c4eb4cf3d14039bea")
      header = {
        "X-API-APP-ID"    => "productidentiefer",
        "X-API-TIMESTAMP" => "1314792296",
        "X-API-TOKEN"     => "1234"
      }

      mock.instance_of(HitfoxCouponApi::Configuration).generate_timestamp { '1314792296' }
      mock(RestClient).get(url,header) { '{ "status" : "banana" }'}
      product = HitfoxCouponApi::Product.new("productidentiefer")
      hsh = product.coupon("abcdedfg-1234-jakl").used

      assert_equal "banana", hsh["status"]
    end

    should "propagate exceptions" do
      product = HitfoxCouponApi::Product.new("productidentiefer")
      mock(RestClient).get.with_any_args do
        raise RuntimeError, "no good"
      end

      assert_raise RuntimeError do
        product.coupon("asdsad").used
      end
    end
  end
end
