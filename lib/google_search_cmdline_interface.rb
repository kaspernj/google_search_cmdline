#This class starts a interactive interface based on a 'in'-IO and 'out-IO. If none is given, then 'stdout' and 'stdin' will be used.
#===Examples
#  interface = Google_search_cmdline::Interface.new(:gsc => gsc)
class Google_search_cmdline::Interface
  ALLOWED_ARGUMENTS = [:debug, :gsc, :io_out, :io_in]
  
  #Constructor.
  def initialize(args = {})
    @args = args
    @args.each do |key, val|
      raise "Invalid argument: '#{key}'." if !ALLOWED_ARGUMENTS.include?(key)
    end
    
    #Used to execute Google-searches.
    @gsc = @args[:gsc]
    raise "No ':gsc'-argument was given. This should be a 'Google_search_cmdline' or compatible." if !@gsc
    
    #Take IO's from arguments or std-IO's.
    if @args[:io_out]
      @io_out = @args[:io_out]
    else
      @io_out = $stdout
    end
    
    if @args[:io_in]
      @io_in = @args[:io_in]
    else
      @io_in = $stdin
    end
    
    #If not synced buffers will ruin the application.
    @io_out.sync = true
    @io_in.sync = true
    
    #Commands that should be called directly on the interface-object.
    direct_cmds = ["exit", "help"]
    
    @io_out.puts "Welcome to Google Search Cmdline."
    
    @io_in.each_line do |line_full|
      begin
        line = line_full[0, line_full.length - 1]
        puts "Got line: '#{line}'." if @args[:debug]
        
        if match = line.match(/^search\s+(.+)$/)
          @io_out.puts "Searching - please wait..."
          search_text = match[1]
          results = @gsc.search(search_text)
          self.cmd_search(results)
        elsif direct_cmds.include?(line)
          self.__send__("cmd_#{line}")
        elsif line.to_s.strip.empty?
          #ignore.
        else
          @io_out.puts "Can't understand that command: '#{line}'. Try 'help' to see available commands."
        end
      rescue => e
        @io_out.puts "An error occurred: '#{e.message}'."
        @io_out.puts "Backtrace:"
        @io_out.puts e.backtrace.join("\n")
        @io_out.puts ""
      end
    end
  end
  
  #Called when 'search [something]'. Shows the results of the search.
  def cmd_search(results)
    count = 0
    results.each do |result|
      count += 1
      
      @io_out.puts "Result #{count} - #{result.title}"
      @io_out.puts "URL: #{result.url}"
      @io_out.puts " "
      
      if count >= 8
        @io_out.puts "The maximum of 8 results was found. Please be more specific."
        break
      end
    end
    
    if count <= 0
      @io_out.puts "No results was found (which is very very weird)."
    end
    
    @io_out.puts ""
  end
  
  #Called when 'exit'.
  def cmd_exit
    @io_out.puts "Goodbye."
    exit
  end
  
  #Called when 'help'. Shows a help-message explaining various available commands.
  def cmd_help
    @io_out.puts "Available commands:"
    @io_out.puts " exit           - Ends the application."
    @io_out.puts " help           - Shows this message."
    @io_out.puts " search [text]  - Executes a Google search and shots the results."
    @io_out.puts ""
  end
end