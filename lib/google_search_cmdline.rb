require "rubygems"
require "http2" #Used for connecting to the Google-search HTTP-server.
require "nokogiri" #Used for parsing HTML.
require "cgi" #Used for HTML-escaping.

#Main class that holds functionality for actually executing the Google-search.
#===Examples
#  gsc = Google_search_cmdline.new
#  gsc.search("something").each do |result|
#    #do something with the result
#  end
class Google_search_cmdline
  #Autoloader for subclasses.
  def self.const_missing(name)
    require "#{File.dirname(__FILE__)}/google_search_cmdline_#{name.to_s.downcase}.rb"
    raise "Still not loaded: '#{name}'." if !Google_search_cmdline.const_defined?(name)
    return Google_search_cmdline.const_get(name)
  end
  
  #This is used to execute a Google-search based on the given text.
  #===Examples
  #  enum = gsc.search("something")
  #  enum.each do |result|
  #    puts "Title: #{result.title}"
  #    puts "URL: #{result.url}"
  #  end
  def search(text)
    return Enumerator.new do |y|
      Http2.new(:host => "www.google.com", :port => 80) do |http|
        escaped_str = CGI.escape(text)
        res = http.get("search?q=#{escaped_str}&oq=#{escaped_str}&sugexp=mod=0&ie=UTF-8")
        
        doc = Nokogiri.HTML(res.body)
        doc.css("li.g > h3.r a").each do |a|
          title = a.content
          google_url = a.attribute("href").content
          
          if !match_url = google_url.match(/\/url\?q=(.+?)&sa=U&ei=/)
            raise "Could not match that Google URL: '#{google_url}'."
          end
          
          url = match_url[1]
          y << Google_search_cmdline::Result.new(:title => title, :url => url)
        end
      end
    end
  end
end