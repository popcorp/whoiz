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

class Object
  def hashify
    self.instance_variables.each_with_object({}) { |var, hash| hash[var.to_s.delete("@")] = self.instance_variable_get(var) }
  end
end

class DiskFetcher
  # Taken from https://developer.yahoo.com/ruby/ruby-cache.html
  def initialize(cache_dir='/tmp/whois')
    @cache_dir = cache_dir
    Dir.mkdir(cache_dir, 0700) unless File.directory?(cache_dir)
  end
  def fetch(domain, max_age=0, func)
    file = Digest::MD5.hexdigest(domain)
    file_path = File.join("", @cache_dir, file)
    if File.exists? file_path
      if Time.now-File.mtime(file_path)<max_age
        data = YAML::load_file(file_path)
        return data
      end
    end

    result = func.call(domain)
    File.open(file_path, "w") do |data|
      data << result.to_yaml
    end
    result
  end
end
$whois = Proc.new do |domain|
  domain = SimpleIDN.to_ascii(domain)
  Whois.lookup(domain)
end

def available?(domain)
  whois =  DiskFetcher.new.fetch(domain, settings.cache, $whois)
  !whois.registered?
end

before do
  response['Access-Control-Allow-Origin'] = '*'
end

["/raw/:domain", "/raw"].each do |path|
  get path do
    begin
      domain = params[:domain]
      whois =  DiskFetcher.new.fetch(domain, settings.cache, $whois)
      return whois.to_s.force_encoding('utf-8').encode
    rescue Exception => e
      e.to_s
    end
  end
end

["/available/:domain/?:extensions?", "/available"].each do |path|
  get path do
    begin
      if params[:extensions].blank?
        domain = params[:domain]
        return {params[:domain] => available?(domain)}.to_json
      end
      result = {}
      base_domain = params[:domain]
      params[:extensions].split(",").each do |ext|
        domain = base_domain + "." + ext
        result[domain] = available?(domain)
      end
      result.to_json
    rescue Exception => e
      e
    end
  end
end
