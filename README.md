Linda Audio Play
================
play audio file with RocketIO::Linda

* https://github.com/shokai/linda-audio-play
* watch a Tuple ["audio", "play", URL] and play.
* write a Tuple ["audio", "play", URL, "start"] and ["audio", "play", URL, "end"] 
* watch a Tuple ["audio", "stop"] and stop.


Dependencies
------------
- afplay command in Mac OS
- Ruby 1.8.7 ~ 2.0.0
- [LindaBase](https://github.com/shokai/linda-base)


Install Dependencies
--------------------

    % gem install bundler foreman
    % bundle install


Run
---

set ENV var "LINDA_BASE" and "LINDA_SPACE"

    % export LINDA_BASE=http://linda.example.com
    % export LINDA_SPACE=test
    % bundle exec ruby linda-audio-play.rb

or

    % LINDA_BASE=http://linda.example.com LINDA_SPACE=test  bundle exec ruby linda-audio-play.rb


Install as Service
------------------

for launchd (Mac OSX)

    % sudo foreman export launchd /Library/LaunchDaemons/ --app linda-audio -u `whoami`
    % sudo launchctl load -w /Library/LaunchDaemons/linda-audio-play-1.plist
