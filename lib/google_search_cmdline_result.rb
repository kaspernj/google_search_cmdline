#This class represents the results when executing Google_search_cmd#search, which is given by the enumerator.
class Google_search_cmdline::Result
  def initialize(args)
    @args = args
    
    raise "Invalid URL: '#{@args[:url]}'." if @args[:url].to_s.strip.empty?
    raise "Invalid title: '#{@args[:title]}'." if @args[:title].to_s.strip.empty?
  end
  
  #Returns the title of the result.
  def title
    return @args[:title]
  end
  
  #Returns the URL of the result.
  def url
    return @args[:url]
  end
end