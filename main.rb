#!/usr/bin/ruby
require 'yaml'
require './client.rb'
require './process.rb'

DEBUG = false

if DEBUG
  require 'pp'
end

STDOUT.sync = true

conf = YAML.load_file("./conf/main.yml")
imap = IMAPClient.new(conf["user"], conf["password"], conf["label"], DEBUG)

while true
  th = Thread.new do
    sleep 600
    imap.idle_done
  end

  last_id = imap.start
  th.kill

  next unless last_id

  mail = imap.fetch_mail last_id..-1 if last_id != -1
  if mail
    mail.each do |m|
      body = imap.process_mail m
      process_body(body, DEBUG)
    end
  end
end
