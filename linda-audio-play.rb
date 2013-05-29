#!/usr/bin/env ruby
require 'rubygems'
require 'em-rocketio-linda-client'
$stdout.sync = true

url   = ENV["LINDA_BASE"]  || ARGV.shift || "http://localhost:5000"
space = ENV["LINDA_SPACE"] || "test"

EM::run do
  puts "connecting.. #{url}"
  linda = EM::RocketIO::Linda::Client.new url
  ts = linda.tuplespace[space]

  linda.io.on :connect do  ## RocketIO's "connect" event
    puts "connect!! <#{linda.io.session}> (#{linda.io.type})"

    ts.watch ["audio", "play"] do |tuple|
      p tuple
      next unless tuple.size == 3
      next unless tuple[2] =~ /https?:\/\/.+/
      puts url = tuple[2]
      ts.write ["audio", "play", url, "start"]
      tmp = "/var/tmp/audio_play.tmp"
      EM::defer do
        system "curl #{url} > #{tmp} && afplay #{tmp} && rm #{tmp}"
        ts.write ["audio", "play", url, "end"]
      end
    end

    ts.watch ["audio", "stop"] do |tuple|
      p tuple
      system "pkill -f afplay"
    end
  end

  linda.io.on :disconnect do
    puts "RocketIO disconnected.."
  end
end
