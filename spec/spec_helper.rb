require 'rack/test'

require File.expand_path '../../main.rb', __FILE__

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

RSpec::Matchers.define :redirect_to do |expected|
  match do |actual|
#    expect(actual.should).to eq(be_redirect)
    expect(actual.location).to include(expected)
  end
end

RSpec.configure { |c| c.include RSpecMixin }
