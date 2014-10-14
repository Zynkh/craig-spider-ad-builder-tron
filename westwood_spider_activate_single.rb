require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'pry'
require_relative 'westwood_spider_ad_class'

class Application

  def self.run(webpage_path)
    source = Nokogiri::HTML(open(webpage_path))
    @page = Ad.new(source)
    puts "Great Success!"
  end

end

webpage_path = ARGV[0]

Application.run(webpage_path)
