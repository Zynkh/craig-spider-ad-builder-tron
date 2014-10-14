require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'pry'
require_relative 'westwood_spider_ad_class'

class Page

  attr_accessor :urls, :fixed_urls

  def initialize(list)
    @urls = list.css('h2 a')
    @fixed_urls = []

    extract_urls
    crawl
  end

  def extract_urls
    @url_file = "temp_url.txt"
    put_urls = File.open(@url_file, "w")
    put_urls.puts @urls
    put_urls.close

    File.open(@url_file, "r") do |file|
      file.readlines.each do |line|
        line.gsub!(/<a href="(.+)".+/,'\1')
        @fixed_urls << ("http://www.westwoodhonda.com/" + line)
      end
    end
    puts "Urls extracted..."
    File.delete(@url_file)
  end

  def crawl
    @fixed_urls.each do |url|
      # puts url
      source = Nokogiri::HTML(open(url))
      # @template = Ad.new(source)
      webloc = "link.webloc"
      web_location = File.open(webloc, "w")
      web_location.puts url
      web_location.close
    end
  end
end

class Application

  def self.run(webpage_path)
    list = Nokogiri::HTML(open(webpage_path))
    @page = Page.new(list)
    puts "Great Success!"
  end

end

webpage_path = ARGV[0]

Application.run(webpage_path)

# TODO
# put all URLS I crawled into a list (or just don't delete the one I make the first time)
# take in an updated list of urls, compare it to the list I currently have, download only the new ones and then add them to the list
# cull the sold cars out of the list.
