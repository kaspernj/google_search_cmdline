require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "GoogleSearchCmdline" do
  it "should be able to execute Google-searches" do
    gsc = Google_search_cmdline.new
    res = gsc.search("kasper").to_a
    
    raise "Expected 10 results but got #{res.length}." if res.length != 10
  end
  
  it "should be able to start a interface and do various commands" do
    require "socket"
    
    puts "Starting socket-server."
    tcpserver = TCPServer.new("localhost", 0)
    tcpclient = TCPSocket.new("localhost", tcpserver.addr[1])
    tcpserverc = tcpserver.accept
    
    puts "Spawning 'Google_search_cmdline'."
    gsc = Google_search_cmdline.new
    
    puts "Starting interface."
    Thread.new do
      begin
        interface = Google_search_cmdline::Interface.new(:debug => true, :gsc => gsc, :io_out => tcpserverc, :io_in => tcpserverc)
      rescue SystemExit
        #ignore - called at the end of the test.
      end
    end
    
    puts "Waiting for welcome-message."
    line_welcome = tcpclient.gets
    raise "Expected welcome-line but got: '#{line_welcome}'." if line_welcome != "Welcome to Google Search Cmdline.\n"
    
    puts "Sending command."
    tcpclient.puts "help"
    
    puts "Getting first line."
    line_acmds = tcpclient.gets
    
    puts "Testing."
    raise "Expected 'Available commands' but got: '#{line_acmds}'." if line_acmds != "Available commands:\n"
    
    #Read the rest of the help-message.
    tcpclient.each_line do |line|
      break if line == "\n"
    end
    
    result_no = nil
    
    tcpclient.puts "search kasper"
    tcpclient.each_line do |line|
      puts "Search: #{line}"
      
      if match = line.match(/^Result (\d+) -/)
        result_no = match[1].to_i
      end
      
      break if line == "\n"
    end
    
    raise "Expected 8 results but got '#{result_no}'." if result_no != 8
    
    tcpclient.puts "exit"
    line_goodbye = tcpclient.gets
    raise "Expected goodbye-message but got: '#{line_goodbye}'." if line_goodbye != "Goodbye.\n"
  end
end
