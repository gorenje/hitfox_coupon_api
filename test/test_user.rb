require File.dirname(__FILE__) + '/helper'

class TestUser < Test::Unit::TestCase
  context "user functionality" do
    setup do
      setup_api_and_header
      @app = HitfoxCouponApi::Application.new("productidentiefer")
    end

    context "user coupon listing" do
      setup do
        @url = ("http://banana.com/one/coupon/1231/show.json?"+
                "hash=09b0150d9aeabb6d61427864f0c637051e69cf40")
      end

      should "fail if status is non zero" do
        mock_rest_client

        assert_raise HitfoxCouponApi::Client::HitfoxApiException do
          @app.user("1231").coupons
        end
      end

      should "succeed if status zero" do
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

        cpns = @app.user("1231").coupons
        assert_equal 2, cpns.count
        assert_equal "fubar", cpns.first.code
        assert_equal "http://example.com?dd", cpns.first.url
        assert_equal "snafu", cpns.last.code
        assert_equal "http://example.com?dd/snahf", cpns.last.url
      end
    end

    context "user coupon purchase" do
      setup do
        @url = ("http://banana.com/one/coupon/1231/buy.json?"+
                "hash=09b0150d9aeabb6d61427864f0c637051e69cf40&count=1")
      end

      should "fail if status non-zero" do
        mock_rest_client

        assert_raise HitfoxCouponApi::Client::HitfoxApiException do
          @app.user("1231").buy_coupon
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

        cpns = @app.user("1231").buy_coupon
        assert_equal 2, cpns.count
        assert_equal "fubar", cpns.first.code
        assert_equal "http://example.com?dd", cpns.first.url
        assert_equal "snafu", cpns.last.code
        assert_equal "http://example.com?dd/snahf", cpns.last.url
      end
    end
  end
end
