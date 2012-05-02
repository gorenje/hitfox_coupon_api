require File.dirname(__FILE__) + '/helper'

class TestOrder < Test::Unit::TestCase
  context "order functionality" do
    setup do
      setup_api_and_header
      @app = HitfoxCouponApi::Application.new("productidentiefer")
    end

    context "reserve coupons" do
      setup do
        @url = ("http://banana.com/one/coupon/1231/reserve.json?"+
                "hash=09b0150d9aeabb6d61427864f0c637051e69cf40&count=2")
      end

      should "fail with status non zero" do
        mock_rest_client
        assert_raise HitfoxCouponApi::Client::HitfoxApiException do
          order = @app.order("1231").reserve(2)
        end
      end

      should "work well enough" do
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
        cpns = @app.order("1231").reserve(2)
        assert_equal 2, cpns.count
        assert_equal "fubar", cpns.first.code
        assert_equal "http://example.com?dd", cpns.first.url
        assert_equal "snafu", cpns.last.code
        assert_equal "http://example.com?dd/snahf", cpns.last.url
      end
    end

    context "paid coupons" do
      setup do
        @url = ("http://banana.com/one/coupon/1231/paid.json?"+
                "hash=09b0150d9aeabb6d61427864f0c637051e69cf40")
      end

      should "fail with status non zero" do
        mock_rest_client
        assert_raise HitfoxCouponApi::Client::HitfoxApiException do
          order = @app.order("1231").paid
        end
      end

      should "work well enough" do
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
        cpns = @app.order("1231").paid
        assert_equal 2, cpns.count
        assert_equal "fubar", cpns.first.code
        assert_equal "http://example.com?dd", cpns.first.url
        assert_equal "snafu", cpns.last.code
        assert_equal "http://example.com?dd/snahf", cpns.last.url
      end
    end

    context "obtain a list of coupons" do
      setup do
        @url = ("http://banana.com/one/coupon/1231/list.json?"+
                "hash=09b0150d9aeabb6d61427864f0c637051e69cf40")
      end

      should "fail with status non zero" do
        mock_rest_client
        assert_raise HitfoxCouponApi::Client::HitfoxApiException do
          order = @app.order("1231").coupons
        end
      end

      should "work well enough" do
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
        cpns = @app.order("1231").coupons
        assert_equal 2, cpns.count
        assert_equal "fubar", cpns.first.code
        assert_equal "http://example.com?dd", cpns.first.url
        assert_equal "snafu", cpns.last.code
        assert_equal "http://example.com?dd/snahf", cpns.last.url
      end
    end
  end
end
