#!/usr/bin/env ruby
require 'rubygems'
require 'em-rocketio-linda-client'
require 'base64'
$stdout.sync = true

url   = ENV["LINDA_BASE"]  || ARGV.shift || "http://localhost:5000"
space = ENV["LINDA_SPACE"] || "test"

EM::run do
  puts "connecting.. #{url}"
  linda = EM::RocketIO::Linda::Client.new url
  ts = linda.tuplespace[space]

  linda.io.on :connect do  ## RocketIO's "connect" event
    puts "connect!! <#{linda.io.session}> (#{linda.io.type})"

    ts.watch ["audio", "play", "url"] do |tuple|
      p tuple
      next unless tuple.size == 4
      next unless tuple[3] =~ /https?:\/\/.+/
      puts url = tuple[3]
      ts.write ["audio", "play", "url", url, "start"]
      tmp = "/var/tmp/audio_play.tmp"
      EM::defer do
        system "curl #{url} > #{tmp} && afplay #{tmp} && rm #{tmp}"
        ts.write ["audio", "play", "url", url, "end"]
      end
    end

    ts.watch ["audio", "play", "base64"] do |tuple|
      next unless tuple.size == 4
      tmp = "/var/tmp/audio_play.tmp"
      ts.write ["audio", "play", "base64", "", "start"]
      File.open(tmp, "w+") do |f|
        f.write Base64.decode64 tuple[3]
      end
      EM::defer do
        system "afplay #{tmp} && rm #{tmp}"
        ts.write ["audio", "play", "base64", "", "end"]
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
