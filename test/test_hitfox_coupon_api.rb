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

    context "coupon reservation for order" do
      setup do
        @url = ("http://banana.com/one/coupon/1231/reserve.json?"+
               "hash=09b0150d9aeabb6d61427864f0c637051e69cf40&count=1")

        @header = {
          "X-API-APP-ID"    => "productidentiefer",
          "X-API-TIMESTAMP" => "1314792296",
          "X-API-TOKEN"     => "1234"
        }
      end

      should "fail if status non-zero" do
        mock.instance_of(HitfoxCouponApi::Configuration).
          generate_timestamp { '1314792296' }
        mock(RestClient).get(@url,@header) { '{ "status" : 1, "msg" : "no message" }'}

        product = HitfoxCouponApi::Application.new("productidentiefer")
        assert_raise HitfoxCouponApi::Client::HitfoxApiException do
          product.order("1231").reserve
        end
      end

      should "generate coupons if all is well" do
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
        mock(RestClient).get(@url,@header) { jsonstr }

        product = HitfoxCouponApi::Application.new("productidentiefer")
        cpns = product.order("1231").reserve
        assert_equal 2, cpns.count
        assert_equal "fubar", cpns.first.code
        assert_equal "http://example.com?dd", cpns.first.url
        assert_equal "snafu", cpns.last.code
        assert_equal "http://example.com?dd/snahf", cpns.last.url
      end
    end

    context "coupon purchase" do
      setup do
        @url = ("http://banana.com/one/coupon/1231/buy.json?"+
               "hash=09b0150d9aeabb6d61427864f0c637051e69cf40&count=1")

        @header = {
          "X-API-APP-ID"    => "productidentiefer",
          "X-API-TIMESTAMP" => "1314792296",
          "X-API-TOKEN"     => "1234"
        }
      end

      should "fail if status non-zero" do
        mock.instance_of(HitfoxCouponApi::Configuration).
          generate_timestamp { '1314792296' }
        mock(RestClient).get(@url,@header) { '{ "status" : 1, "msg" : "no message" }'}

        product = HitfoxCouponApi::Application.new("productidentiefer")
        assert_raise HitfoxCouponApi::Client::HitfoxApiException do
          product.user("1231").buy_coupon
        end
      end

      should "generate coupons if all is well" do
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
        mock(RestClient).get(@url,@header) { jsonstr }

        product = HitfoxCouponApi::Application.new("productidentiefer")
        cpns = product.user("1231").buy_coupon
        assert_equal 2, cpns.count
        assert_equal "fubar", cpns.first.code
        assert_equal "http://example.com?dd", cpns.first.url
        assert_equal "snafu", cpns.last.code
        assert_equal "http://example.com?dd/snahf", cpns.last.url
      end
    end

    context "coupon info" do
      setup do
        @url = ("http://banana.com/one/coupon/abcdedfg-1234-jakl/info.json?"+
                "hash=97c68554af339f1017155b1c4eb4cf3d14039bea")
        @header = {
          "X-API-APP-ID"    => "productidentiefer",
          "X-API-TIMESTAMP" => "1314792296",
          "X-API-TOKEN"     => "1234"
        }
      end

      should "work if status is zero" do
        mock.instance_of(HitfoxCouponApi::Configuration).
          generate_timestamp { '1314792296' }
        jsonstr = {
          :status => 0,
          :coupons => [{"in_game_coupon" => {
                           :code         => 'fubar',
                           :download_url => "http://example.com?dd",
                           :state        => 'all good',
                           :app_id       => "1231121",
                         }},
                       {"fubar" => {
                           :code         => 'snafu',
                           :download_url => "http://example.com?dd/snahf",
                           :state        => 'all bad',
                           :app_id       => 12131412,
                         }}]}.to_json
        mock(RestClient).get(@url,@header) { jsonstr }

        product = HitfoxCouponApi::Application.new("productidentiefer")

        cpns = product.coupon("abcdedfg-1234-jakl").info
        assert_equal 2, cpns.count

        cpn = cpns.first
        assert_equal "1231121", cpn.app_id
        assert_equal "fubar", cpn.code
        assert_equal "http://example.com?dd", cpn.url
        assert_equal 'all good', cpn.state

        cpn = cpns.last
        assert_equal 12131412, cpn.app_id
        assert_equal "http://example.com?dd/snahf", cpn.url
        assert_equal 'all bad', cpn.state
        assert_equal 'snafu', cpn.code
      end

      should "die if the status is not zero" do
        mock.instance_of(HitfoxCouponApi::Configuration).
          generate_timestamp { '1314792296' }
        mock(RestClient).get(@url,@header) { '{ "status" : "banana" }'}

        product = HitfoxCouponApi::Application.new("productidentiefer")

        assert_raise HitfoxCouponApi::Client::HitfoxApiException do
          product.coupon("abcdedfg-1234-jakl").info
        end
      end

    end

    context "coupon adding" do
      setup do
        @url = ("http://banana.com/one/coupons/create.json?"+
                "hash=6f6e6aab956d49491b799daf4ed6f8cdadb3ee59")
        @header = {
          "X-API-APP-ID"    => "productidentiefer",
          "X-API-TIMESTAMP" => "1314792296",
          "X-API-TOKEN"     => "1234"
        }
      end

      should "generate hash based on count" do
        ary = [:one,:two,:three,:four]
        mock.instance_of(HitfoxCouponApi::Configuration).
          generate_timestamp { '1314792296' }
        mock(RestClient).post(@url.gsub(/6f6e6aab956d49491b799daf4ed6f8cdadb3ee59/,
                                        "b99ac8c4a3027c6bbe759cfc8179bd338bfd6e14"),
                              { :coupons => ary}, @header) { '{ "status" : 1 }'}

        HitfoxCouponApi::Application.new("productidentiefer").add_coupons(ary)
      end

      should "generate hash based on count not content of array" do
        ary = [:oned,:twod,:dthree,:dfour]
        mock.instance_of(HitfoxCouponApi::Configuration).
          generate_timestamp { '1314792296' }
        mock(RestClient).post(@url.gsub(/6f6e6aab956d49491b799daf4ed6f8cdadb3ee59/,
                                        "b99ac8c4a3027c6bbe759cfc8179bd338bfd6e14"),
                              { :coupons => ary}, @header) { '{ "status" : 1 }'}

        HitfoxCouponApi::Application.new("productidentiefer").add_coupons(ary)
      end

      should "raise exception with bang" do
        ary = [:one,:two,:three]
        mock.instance_of(HitfoxCouponApi::Configuration).
          generate_timestamp { '1314792296' }
        mock(RestClient).post(@url, { :coupons => ary}, @header) { '{ "status" : 1 }'}

        assert_raise HitfoxCouponApi::Client::HitfoxApiException do
          HitfoxCouponApi::Application.new("productidentiefer").add_coupons!(ary)
        end
      end

      should "work with bang also" do
        ary = [:one,:two,:three]
        mock.instance_of(HitfoxCouponApi::Configuration).
          generate_timestamp { '1314792296' }
        mock(RestClient).post(@url, { :coupons => ary}, @header) { '{ "status" : 0 }'}

        HitfoxCouponApi::Application.new("productidentiefer").add_coupons!(ary)
      end

      should "work" do
        ary = [:one,:two,:three]
        mock.instance_of(HitfoxCouponApi::Configuration).
          generate_timestamp { '1314792296' }
        mock(RestClient).post(@url, { :coupons => ary}, @header) { '{ "status" : 0 }'}

        HitfoxCouponApi::Application.new("productidentiefer").add_coupons(ary)
      end
    end

    context "coupon used" do
      setup do
        @url = ("http://banana.com/one/coupon/abcdedfg-1234-jakl/used.json?"+
                "hash=97c68554af339f1017155b1c4eb4cf3d14039bea")
        @header = {
          "X-API-APP-ID"    => "productidentiefer",
          "X-API-TIMESTAMP" => "1314792296",
          "X-API-TOKEN"     => "1234"
        }
      end

      should "have a bang variation for throwing exceptions" do
        product = HitfoxCouponApi::Application.new("productidentiefer")
        cpn = product.coupon("abcdedfg-1234-jakl")
        mock(cpn).used { { "status" => 1 }}
        assert_raise HitfoxCouponApi::Client::HitfoxApiException do
          cpn.used!
        end
      end

      should "have a bang variation for returning true" do
        product = HitfoxCouponApi::Application.new("productidentiefer")
        cpn = product.coupon("abcdedfg-1234-jakl")
        mock(cpn).used { { "status" => 0 }}
        assert cpn.used
      end

      should "generate the correct hash value" do
        mock.instance_of(HitfoxCouponApi::Configuration).
          generate_timestamp { '1314792296' }
        mock(RestClient).get(@url,@header) { '{ "status" : "banana" }'}

        product = HitfoxCouponApi::Application.new("productidentiefer")
        hsh = product.coupon("abcdedfg-1234-jakl").used

        assert_equal "banana", hsh["status"]
      end

      should "provide a shortcut application instanciation method" do
        mock.instance_of(HitfoxCouponApi::Configuration).
          generate_timestamp { '1314792296' }
        mock(RestClient).get(@url,@header) { '{ "status" : "banana" }' }

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
end
