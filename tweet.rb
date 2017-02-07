#!/usr/bin/ruby
require 'twitter'
require 'yaml'

yaml = YAML.load_file("./conf/twitter.yml")

$tw_client = Twitter::REST::Client.new do |config|
    config.consumer_key = yaml["consumer_key"]
    config.consumer_secret = yaml["consumer_secret"]
    config.access_token = yaml["access_token"]
    config.access_token_secret = yaml["access_token_secret"]
end

def tweet(msg, img = nil)
    Thread.new do
        begin
            if img
                open(img) do |tmp|
                    $tw_client.update_with_media(msg, tmp)
                end
            else
                $tw_client.update msg
            end
        rescue
            $tw_client.update msg
        end
    end
end
