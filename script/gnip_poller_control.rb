#!/usr/bin/env ruby
ENV["RAILS_ENV"] ||= "development"
require 'rubygems'
require 'daemons'

ROOT = File.expand_path(File.dirname(__FILE__)+'/../')

Daemons.run_proc("gnip_poller", :dir_mode => :normal,
                                :dir => "#{ROOT}/log/",
                                :log_output => true,
                                :backtrace => true) do

  require "#{ROOT}/config/environment" 
  GnipPoller.new.run
end