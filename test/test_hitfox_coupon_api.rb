require File.dirname(__FILE__)+'/helper'

class TestHitfoxCouponApi < Test::Unit::TestCase

  context "hitfox api" do
    setup do
      HitfoxCouponApi.configure do |c|
        c.api_token    = "1234"
        c.api_secret   = "2143abce"
        c.api_version  = "one"
        c.api_endpoint = "http://banana.com"
      end
    end

    context "configuration can be application specific" do
      should "have default global configuration" do
        app1 = HitfoxCouponApi.application("12131")
        assert_nil app1.configuration
        assert_equal "http://banana.com", app1.user("121").configuration.api_endpoint
      end

      should "can have application specific configuration" do
        app1 = HitfoxCouponApi.application("12131")
        assert_nil app1.configuration
        user = app1.user("121")
        assert_equal "http://banana.com", user.configuration.api_endpoint

        app1.configure { |c| c.api_endpoint = "http://new.endpoint.com" }
        assert_equal "http://new.endpoint.com", app1.user("121").configuration.api_endpoint
        assert_equal "http://new.endpoint.com", user.configuration.api_endpoint

        # but remains application specific
        app2 = HitfoxCouponApi.application("12131")
        assert_equal "http://banana.com", app2.user("121").configuration.api_endpoint
        assert_equal "http://new.endpoint.com", app1.user("1").configuration.api_endpoint
      end

      should "global configuration provides default values for things not set" do
        app1 = HitfoxCouponApi.application("12131")
        app1.configure { |c| c.api_endpoint = "http://new.endpoint.com" }

        user = app1.user("1211")
        url = ("http://new.endpoint.com/one/coupon/1211/buy.json?"+
               "hash=5d13dc25ee89649c5e02c3b93f0f9f4faa6d6d21&count=1")

        header = {
          "X-API-APP-ID"    => "12131",
          "X-API-TIMESTAMP" => "1314792296",
          "X-API-TOKEN"     => "1234"
        }
        mock(app1.configuration).generate_timestamp { "1314792296" }
        mock(RestClient).get(url,header) { '{ "status" : 1, "msg" : "no message" }'}

        assert_raise HitfoxCouponApi::Client::HitfoxApiException do
          user.buy_coupon
        end
      end
    end

    context "coupon purchase" do
      should "fail if status non-zero" do
        url = ("http://banana.com/one/coupon/1231/buy.json?"+
               "hash=09b0150d9aeabb6d61427864f0c637051e69cf40&count=1")

        header = {
          "X-API-APP-ID"    => "productidentiefer",
          "X-API-TIMESTAMP" => "1314792296",
          "X-API-TOKEN"     => "1234"
        }

        mock.instance_of(HitfoxCouponApi::Configuration).
          generate_timestamp { '1314792296' }
        mock(RestClient).get(url,header) { '{ "status" : 1, "msg" : "no message" }'}

        product = HitfoxCouponApi::Application.new("productidentiefer")
        assert_raise HitfoxCouponApi::Client::HitfoxApiException do
          product.user("1231").buy_coupon
        end
      end

      should "generate coupons of all is well" do
        url = ("http://banana.com/one/coupon/1231/buy.json?"+
               "hash=09b0150d9aeabb6d61427864f0c637051e69cf40&count=1")

        header = {
          "X-API-APP-ID"    => "productidentiefer",
          "X-API-TIMESTAMP" => "1314792296",
          "X-API-TOKEN"     => "1234"
        }

        jsonstr = {
          :status => 0,
          :coupons => [{"in_game_coupon" => {
                         :code => 'fubar',
                         :download_url => "http://example.com?dd"
                       }},
                       {"fubar" => {
                         :code => 'snafu',
                         :download_url => "http://example.com?dd/snahf"
                       }}]}.to_json
        mock.
          instance_of(HitfoxCouponApi::Configuration).generate_timestamp { '1314792296' }
        mock(RestClient).get(url,header) { jsonstr }

        product = HitfoxCouponApi::Application.new("productidentiefer")
        cpns = product.user("1231").buy_coupon
        assert_equal 2, cpns.count
        assert_equal "fubar", cpns.first.code
        assert_equal "http://example.com?dd", cpns.first.url
        assert_equal "snafu", cpns.last.code
        assert_equal "http://example.com?dd/snahf", cpns.last.url
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

      product = HitfoxCouponApi::Application.new("productidentiefer")
      hsh = product.coupon("abcdedfg-1234-jakl").used

      assert_equal "banana", hsh["status"]
    end

    should "provide a shortcut application instanciation method" do
      url = ("http://banana.com/one/coupon/abcdedfg-1234-jakl/used.json?"+
             "hash=97c68554af339f1017155b1c4eb4cf3d14039bea")
      header = {
        "X-API-APP-ID"    => "productidentiefer",
        "X-API-TIMESTAMP" => "1314792296",
        "X-API-TOKEN"     => "1234"
      }

      mock.instance_of(HitfoxCouponApi::Configuration).generate_timestamp { '1314792296' }
      mock(RestClient).get(url,header) { '{ "status" : "banana" }' }

      hsh = HitfoxCouponApi.application("productidentiefer").
        coupon("abcdedfg-1234-jakl").used

      assert_equal "banana", hsh["status"]
    end

    should "propagate exceptions" do
      product = HitfoxCouponApi::Application.new("productidentiefer")
      mock(RestClient).get.with_any_args do
        raise RuntimeError, "no good"
      end

      assert_raise RuntimeError do
        product.coupon("asdsad").used
      end
    end
  end
end
