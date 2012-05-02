require File.dirname(__FILE__) + '/helper'

class TestCoupon < Test::Unit::TestCase
  context "coupon funcationality" do
    setup do
      setup_api_and_header
      @app = HitfoxCouponApi::Application.new("productidentiefer")
    end

    context "coupon available" do
      setup do
        @url = ("http://banana.com/one/coupons/available.json?"+
                "hash=dfb33057c8670f2f088bf5d12ea30a00955cdfa8&count=1")
      end

      should "fail if status non zero" do
        mock_rest_client
        assert !@app.available?(1)
      end

      should "fail if status non existent" do
        mock_rest_client('{}')
        assert !@app.available?(1)
      end

      should "succeed if status is zero" do
        mock_rest_client('{"status" : 0}')
        assert @app.available?(1)
      end
    end

    context "coupon reservation for order" do
      setup do
        @url = ("http://banana.com/one/coupon/1231/reserve.json?"+
                "hash=09b0150d9aeabb6d61427864f0c637051e69cf40&count=1")
      end

      should "fail if status non-zero" do
        mock_rest_client
        assert_raise HitfoxCouponApi::Client::HitfoxApiException do
          @app.order("1231").reserve
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
        mock_rest_client(jsonstr)

        cpns = @app.order("1231").reserve
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
      end

      should "work if status is zero" do
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
        mock_rest_client(jsonstr)

        cpns = @app.coupon("abcdedfg-1234-jakl").info
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
        mock_rest_client('{ "status" : "banana" }')

        assert_raise HitfoxCouponApi::Client::HitfoxApiException do
          @app.coupon("abcdedfg-1234-jakl").info
        end
      end
    end

    context "coupon adding" do
      setup do
        @url = ("http://banana.com/one/coupons/create.json?"+
                "hash=6f6e6aab956d49491b799daf4ed6f8cdadb3ee59")
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

        @app.add_coupons(ary)
      end

      should "raise exception with bang" do
        ary = [:one,:two,:three]
        mock.instance_of(HitfoxCouponApi::Configuration).
          generate_timestamp { '1314792296' }
        mock(RestClient).post(@url, { :coupons => ary}, @header) { '{ "status" : 1 }'}

        assert_raise HitfoxCouponApi::Client::HitfoxApiException do
          @app.add_coupons!(ary)
        end
      end

      should "work with bang also" do
        ary = [:one,:two,:three]
        mock.instance_of(HitfoxCouponApi::Configuration).
          generate_timestamp { '1314792296' }
        mock(RestClient).post(@url, { :coupons => ary}, @header) { '{ "status" : 0 }'}

        @app.add_coupons!(ary)
      end

      should "work" do
        ary = [:one,:two,:three]
        mock.instance_of(HitfoxCouponApi::Configuration).
          generate_timestamp { '1314792296' }
        mock(RestClient).post(@url, { :coupons => ary}, @header) { '{ "status" : 0 }'}

        @app.add_coupons(ary)
      end
    end

    context "coupon used" do
      setup do
        @url = ("http://banana.com/one/coupon/abcdedfg-1234-jakl/used.json?"+
                "hash=97c68554af339f1017155b1c4eb4cf3d14039bea")
      end

      should "have a bang variation for throwing exceptions" do
        cpn = @app.coupon("abcdedfg-1234-jakl")

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
        mock_rest_client('{ "status" : "banana" }')

        hsh = @app.coupon("abcdedfg-1234-jakl").used

        assert_equal "banana", hsh["status"]
      end

      should "propagate exceptions" do
        mock(RestClient).get.with_any_args do
          raise RuntimeError, "no good"
        end

        assert_raise RuntimeError do
          @app.coupon("asdsad").used
        end
      end
    end
  end
end
