#!/usr/bin/env ruby
require 'rubygems'
require 'em-rocketio-linda-client'
require 'base64'
$stdout.sync = true

if ARGV.empty?
  STDERR.puts "error! Filename or URL rquired."
  exit 1
end
puts input = ARGV.shift
url   = ENV["LINDA_BASE"]  || ARGV.shift || "http://localhost:5000"
space = ENV["LINDA_SPACE"] || "test"

EM::run do
  puts "connecting.. #{url}"
  linda = EM::RocketIO::Linda::Client.new url
  ts = linda.tuplespace[space]

  linda.io.on :connect do  ## RocketIO's "connect" event
    puts "connect!! <#{linda.io.session}> (#{linda.io.type})"

    if input =~ /^https?:\/\/.+/
      ts.write ["audio", "play", "url", input]
    else
      File.open input do |f|
        ts.write ["audio", "play", "base64", Base64.encode64(f.read)]
      end
      EM::add_timer 3 do
        exit
      end
    end
  end

  linda.io.on :disconnect do
    puts "RocketIO disconnected.."
    exit 1
  end
end
