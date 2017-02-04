#!/usr/bin/ruby
require './AnalyzeReport.rb'
require './tweet.rb'

def create_msg(p)
  msg = ""

  if result[:portal][:name] and result[:attacked_by]
    msg += result[:portal][:name] + " is attacked by " + result[:attacked_by] + "\n"
  end

  if result[:portal][:status]
    msg += "Owner: " + (result[:portal][:status][:owner]? result[:portal][:status][:owner] : "Uncaptured") + "\n"
    msg += "Level: " + result[:portal][:status][:level].to_s + "\n"
    msg += "Health: " + result[:portal][:status][:health].to_s + "%\n"
  end

  if result[:about_damage]
    msg += result[:about_damage][:count].to_s + " " + result[:about_damage][:to]
    msg += "s" if result[:about_damage][:count] > 1
    msg += " destroyed\n"
    msg += (result[:about_damage][:remaining] == 0? "No" : result[:about_damage][:remaining].to_s) + " resonator"
    msg += "s" unless result[:about_damage][:remaining] < 2
    msg += " remaining\n"
  end
  
  return msg

end

def process_body(body, debug = false)
  r = AnalyzeReport.new body
  result = r.get_all

  unless result.nil?
    msg = create_msg result
    if msg
      puts msg
      tweet(msg, result[:portal][:img])
    end
  end

end