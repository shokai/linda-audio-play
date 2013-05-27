#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra/rocketio/linda/client'
$stdout.sync = true

url   = ENV["LINDA_BASE"]  || ARGV.shift || "http://localhost:5000"
space = ENV["LINDA_SPACE"] || "test"
puts "connecting.. #{url}"
linda = Sinatra::RocketIO::Linda::Client.new url
ts = linda.tuplespace[space]

linda.io.on :connect do  ## RocketIO's "connect" event
  puts "connect!! <#{linda.io.session}> (#{linda.io.type})"
  ts.watch ["audio", "play"] do |tuple|
    next unless tuple.size == 3
    next unless tuple[2] =~ /https?:\/\/.+/
    puts url = tuple[2]
    ts.write ["audio", "play", url, "start"]
    tmp = "/var/tmp/audio_play.tmp"
    system "curl #{url} > #{tmp} && afplay #{tmp} && rm #{tmp}"
    ts.write ["audio", "play", url, "end"]
  end
end

linda.io.on :disconnect do
  puts "RocketIO disconnected.."
end

linda.wait
