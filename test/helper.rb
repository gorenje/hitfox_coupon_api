require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'test/unit'
require 'shoulda'
require 'rr'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'hitfox_coupon_api'

class Test::Unit::TestCase
  include RR::Adapters::TestUnit

  def setup_api_and_header
    HitfoxCouponApi.configure do |c|
      c.api_token    = "1234"
      c.api_secret   = "2143abce"
      c.api_version  = "one"
      c.api_endpoint = "http://banana.com"
    end

    @header = {
      "X-API-APP-ID"    => "productidentiefer",
      "X-API-TIMESTAMP" => "1314792296",
      "X-API-TOKEN"     => "1234"
    }
  end

  def mock_rest_client(jsonstr = nil)
    jsonstr ||= '{ "status" : 1, "msg" : "no message" }'
    mock.instance_of(HitfoxCouponApi::Configuration).
      generate_timestamp { '1314792296' }
    mock(RestClient).get(@url,@header) { jsonstr }
  end
end
