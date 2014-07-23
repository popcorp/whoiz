require File.expand_path '../spec_helper.rb', __FILE__
describe "The Whoiz Application", :type => :controller do
  include Rack::Test::Methods
  it "should redirect to the github page on 404" do
     ['/', '/random_string'].each do |i|
	get i
	expect(last_response).to redirect_to('https://github.com/popcorp/whoiz')
     end
   end
end
