#!/usr/bin/ruby
require "readline"
require 'nokogiri'

class AnalyzeReport

    # initialize
    def initialize mail
        if mail.is_a? String
            @mail = mail
            @doc = Nokogiri::HTML(mail)
            analyze
        else
            return 0
        end
    end

    # analyze
    def analyze

        # ATTACKER
        @attacked_by = @doc.xpath("//table//table//tr").last.xpath("//tbody//td/div/span")[0].text

        # AGENT
        r = @doc.xpath('//tr[2]//tr[1]//span')
        @agent = {
            name: r[1].text,
            faction: r[3].text,
            level: r[5].text.gsub(/L/, '').to_i
        }

        # PORTAL
        r = @doc.xpath("//table//table//tr[3]//div")
        @portal = {
            name: r[0].content,
            link: r[1].xpath("a/@href").to_s,
            img: @doc.xpath("//table//table//tr[4]//img[1]/@src")[0].to_s,
        }

        #PORTAL STATUS
        if @doc.xpath('//div/table')[-1].xpath('//div')[-1].text.gsub(/(\n|\r| )/, "").match(/STATUS:Level([0-9]{1,})Health:([0-9]{1,})%Owner:(.+)/)
            @portal[:status] = {
                level: $1.to_i,
                health: $2.to_i,
                owner: $3 == "[uncaptured]" ? nil : $3,
            }
        end

        # PORTAL GEO
        if @portal[:link].match /ll=([-0-9.]+),([-0-9.]+)/
			@portal[:geo] = {
				lat: $1.to_f,
				lng: $2.to_f
			}
		end

		# ABOUT DAMAGE
		if @doc.xpath("//table//table//tr").last.xpath("//tbody//td[1]/div").text.gsub(/(\n|\r| )/, "").match(/([0-9]+)(Link|Field|Resonator|Mod)s*destroyed.+([0-9]|No)remaining/)
			@about_damage = {
				to: $2,
				count: $1.to_i,
				remaining: $3 == "No"? 0 : $3.to_i,
			}
		end

		# DAMEGED LINK
		@links_destroyed = @mail.match(/LINK(S*) DESTROYED/)? true : false

	end

	def get_agent
		return @agent
	end

	def get_portal
		return @portal
	end

	def get_all
		return {
			attacked_by: @attacked_by,
			agent: @agent, 
			portal: @portal,
			about_damage: @about_damage,
			links_destroyed: @links_destroyed,
		}
	end
end
