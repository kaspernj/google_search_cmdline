#!/usr/bin/env ruby

#This file starts the 'Google_search_cmdline'-application.

require "#{File.realpath(File.dirname(__FILE__))}/../lib/google_search_cmdline.rb"

gsc = Google_search_cmdline.new
interface = Google_search_cmdline::Interface.new(:gsc => gsc)