require File.dirname(__FILE__)+'/helper'

class TestHitfoxCouponApi < Test::Unit::TestCase

  context "hitfox api" do
    setup do
      setup_api_and_header
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

    context "client helpers" do
      setup do
        @cpnres = {
          "status" => 0,
          "coupons" => [ "some_key" => {
                           "app_id"       => 'fubar',
                           "code"         => "edoc",
                           "download_url" => "url",
                           "state"        => "active"
                         }
                       ]
        }

        @client = Class.new(HitfoxCouponApi::Client) do
          def initialize(app)
            @application = app
          end
        end.new(HitfoxCouponApi::Application.new("fubar"))
      end

      should "be able to generate a url" do
        assert_equal "http://banana.com", @client.generate_url("",[])
        assert_equal "http://banana.com/path", @client.generate_url("/%s",["path"])
        assert_equal("http://banana.com/path?c=%2B%3F%26%2F",
                     @client.generate_url("/%s?c=%s",["path","+?&/"]))
      end

      should "handle a coupon return value - raise exception if status non zero" do
        assert_raise HitfoxCouponApi::Client::HitfoxApiException do
          @client.handle_coupon_results({"status" => 1})
        end
      end

      should "handle coupon results" do
        cpns = @client.handle_coupon_results(@cpnres)
        assert_equal 1, cpns.count
        assert_equal "edoc", cpns.first.code
        assert_equal "url", cpns.first.url
        assert_equal nil, cpns.first.state
      end

      should "handle coupon results and yield to block" do
        cpns = @client.handle_coupon_results(@cpnres) do |cc|
          HitfoxCouponApi::Coupon.new(HitfoxCouponApi::Application.new(cc["app_id"]),
                                      cc["code"], cc["download_url"]).tap do |cpn|
            cpn.state = cc["state"]
          end
        end
        assert_equal 1, cpns.count
        assert_equal "edoc", cpns.first.code
        assert_equal "url", cpns.first.url
        assert_equal "active", cpns.first.state
      end
    end
  end
end
