require 'nokogiri'
require 'pp'

# 参考
# https://github.com/Sabara/ingressmap/blob/master/ingressmap.js#L554

FILE_PATH = '../samples/2.html'

@doc = Nokogiri::HTML(File.read(FILE_PATH, :encoding => Encoding::UTF_8))

r = @doc.xpath('//table[@width="750px"]/tbody/tr[2]/td/table[@width="700px"]/tbody/tr')

reports = {}
i = 0 # for reports
j = 0 # for linked portals

r.each do |s|

	# Agent 情報
	unless s.xpath('td[@valign="top"][@style="font-size: 13px; padding-bottom: 1.5em;"]').empty?
		#puts s.to_html
		s.xpath('td[@valign="top"][@style="font-size: 13px; padding-bottom: 1.5em;"]').text.match(/Agent Name:(.+)Faction:(.+)Current Level:L([0-9]{1,2})$/) do |m|
			reports[:agent] = {
				:codename => m[1],
				:faction => m[2],
				:level => m[3].to_i
			}
		end
	end

	# <div>DAMAGE REPORT</div>
	unless s.xpath('td[@style="font-size: 17px; padding-bottom: .2em; border-bottom: 2px solid #403F41;"]').empty?
		# puts s.to_html
	end

	# <td style="font-size: 17px;padding-bottom: .2em;border-bottom: 2px solid #403F41;text-transform: uppercase;"></td>
	# レポートの切り替わり
	unless s.xpath('td[@style="font-size: 17px;padding-bottom: .2em;border-bottom: 2px solid #403F41;text-transform: uppercase;"]').empty?
		i += 1
		j = 0
		reports[i] = {}
	end

	# ポータル情報(名前,アドレス)
	unless s.xpath('td[@style="padding-top: 1em; padding-bottom: 1em;"]').empty?
		reports[i] = {:portal => {
			:name => s.xpath('td[@style="padding-top: 1em; padding-bottom: 1em;"]/div[1]').text,
			:intel => s.xpath('td[@style="padding-top: 1em; padding-bottom: 1em;"]/div/a').attribute('href').to_s
			}}
		# puts s.to_html
	end

	# ポータル情報(画像)
	unless s.xpath('td[@style="overflow: hidden;"]/table[@cellpadding="0"][@cellspacing="0"][@border="0"]').empty?
		reports[i][:portal][:photo] = s.xpath('//div[@style="width: auto; height: 160px; float: left; display: inline-block;"]/img').attribute("src").to_s
		reports[i][:portal][:intel_image] = s.xpath('//div[@style="width: auto; height: 160px; float: left; display: inline-block; overflow:hidden;"]/img').attribute("src").to_s
	end

	# ダメージ情報
	unless s.xpath('td[@style="padding: 1em 0;"]').empty?
		# ダメージ詳細
		about_damage = s.xpath('td[@style="padding: 1em 0;"]/table/td[@width="400px"]/div')
		reports[i][:attacked_by] = about_damage.xpath('span[@style="color: #428F43;"]').text
		
		# DAMAGE:9 Links destroyed by godiego at 10:00 hrs GMTNo remaining Resonators detected on this Portal.
		about_damage.text.match(/([0-9]{1}) (.+) destroyed by .+ at ([0-9]{1,2}:[0-9]{1,2}) hrs GMT/) do |m|
			reports[i][:portal][:damage] = {
				:count => m[1].to_i,
				:type => m[2].gsub(/s$/, ""),
				:date => m[3]
			}
		end

		# レゾネータの残量を取る，けどいらないかな
		#resonators_remaining_count = about_damage.text.scan(/No Remaining Resonators/).empty?? about_damage.text.scan(/([0-9]) Resonators? remaining/)[0][0].to_i : 0
		
		# STATUS:Level 1Health: 3%Owner: tujiyan
		portal_status = s.xpath('td[@style="padding: 1em 0;"]/table/td[2]/div')
		reports[i][:status] = {
			:level => portal_status.text.match(/Level ([1-8])/)[1].to_i,
			:health => portal_status.text.match(/Health: ([0-9]{1,})%/)[1].to_i,
			:owner => portal_status.text.match(/Owner: (.+)/)[1]
		}
	end

	# リンクのつながっていたポータルの情報を抜く
	unless s.xpath('td/table[@cellpadding="0"][@cellspacing="0"][@border="0"][@width="700px"]').empty? or s.text == "LINKS DESTROYED" or s.text.match /on this Portal./
		
		if j == 0
			reports[i][:linked_portals] = []
		end

		# intel
		r = s.xpath('td/table[@cellpadding="0"][@cellspacing="0"][@border="0"][@width="700px"]/td/a')
		unless r.empty?
			intel = r.attribute('href').to_s
		end

		s.xpath('td/table[@cellpadding="0"][@cellspacing="0"][@border="0"][@width="700px"]/td').text.match(/(.+): (.+)/) do |m|
			puts m[1] + j.to_s + i.to_s
			reports[i][:linked_portals][j] = {
				:intel => intel,
				:name => m[1],
				:address => m[2]
			}
			j += 1
		end
	end
end

pp reports
puts i