require 'sinatra'
require 'whois'
require 'json'
require 'ostruct'
require 'digest'
require 'yaml'
require 'simpleidn'

CONFIG = YAML.load_file("config.yml") unless defined? CONFIG
set :port => CONFIG['port'] || 4567
set :bind => CONFIG['bind'] || "0.0.0.0"
set :cache => CONFIG['cache'] || 600
       
class DiskFetcher
   # Taken from https://developer.yahoo.com/ruby/ruby-cache.html
   def initialize(cache_dir='/tmp')
      @cache_dir = cache_dir
   end
   def fetch(domain, max_age=0, func)
      file = Digest::MD5.hexdigest(domain)
      file_path = File.join("", @cache_dir, file)
      if File.exists? file_path
         return File.new(file_path).read if Time.now-File.mtime(file_path)<max_age
      end
         
      result = func.call(domain)
      File.open(file_path, "w") do |data|
         data << result
      end
      result
   end
end   
   
$whois = Proc.new do |domain|
        Whois.lookup(domain).to_s.force_encoding('utf-8').encode
end
        
before do
        response['Access-Control-Allow-Origin'] = '*'
end
                                                                   
["/:domain", "/"].each do |path|
  get path do
        begin
                domain = SimpleIDN.to_ascii(params[:domain])
                {:result => DiskFetcher.new.fetch(domain, settings.cache, $whois)}.to_json
        rescue Exception => e
                {:error => e}.to_json
        end
  end
end
