require 'sinatra'
require 'whois'
require 'haml'
require 'json'
require 'ostruct'
require 'digest'

class DiskFetcher
   # Taken from https://developer.yahoo.com/ruby/ruby-cache.html
   def initialize(cache_dir='/tmp')
      @cache_dir = cache_dir
   end
   def whois(domain, max_age=0)
      file = Digest::MD5.digest(domain)
      file_path = File.join("", @cache_dir, file)
      if File.exists? file_path
         return File.new(file_path).read if Time.now-File.mtime(file_path)<max_age
      end
      
      File.open(file_path, "w") do |data|
         data << Whois.lookup(domain).to_s.force_encoding('utf-8').encode
      end
      data
   end
end

before do
	response['Access-Control-Allow-Origin'] = '*'
end

get '/:domain' do
	begin
		@output = {:result => DiskFetcher.new.whois(params[:domain], 60)}.to_json
	rescue Exception => e
		{:error => e}.to_json
	end
end
