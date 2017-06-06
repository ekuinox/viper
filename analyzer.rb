require 'nokogiri'

def AnalyzeReport mail
	@doc = Nokogiri::HTML(mail)
	
	r = @doc.xpath('//table[@width="750px"]/tbody/tr[2]/td/table[@width="700px"]/tbody/tr')
	
	reports = {}
	i = -1 # for reports
	j = 0 # for linked portals
	
	r.each do |s|
		begin
			# Agent 情報
			unless s.xpath('td[@valign="top"][@style="font-size: 13px; padding-bottom: 1.5em;"]').empty?
				#puts s.to_html
				s.xpath('td[@valign="top"][@style="font-size: 13px; padding-bottom: 1.5em;"]').text.match(/Agent Name:(.+)Faction:(.+)Current Level:L([0-9]{1,2})$/) do |result|
					reports[:agent] = {
						:codename => result[1],
						:faction => result[2],
						:level => result[3].to_i
					}
				end
			end
		
			# <div>DAMAGE REPORT</div>
			unless s.xpath('td[@style="font-size: 17px; padding-bottom: .2em; border-bottom: 2px solid #403F41;"]').empty?
				i += 1
				reports[i] = {}
				# puts s.to_html
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
				about_damage.text.match(/([0-9]{1}) (.+) destroyed by .+ at ([0-9]{1,2}:[0-9]{1,2}) hrs GMT/) do |result|
					reports[i][:portal][:damage] = {
						:count => result[1].to_i,
						:type => result[2].gsub(/s$/, ""),
						:date => result[3]
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
		
				s.xpath('td/table[@cellpadding="0"][@cellspacing="0"][@border="0"][@width="700px"]/td').text.match(/(.+): (.+)/) do |result|
					reports[i][:linked_portals][j] = {
						:intel => intel,
						:name => result[1],
						:address => result[2]
					}
					j += 1
				end
			end
		rescue
			return 0
		end
	end
	return reports
end


=begin
pp reports =>
{:agent=>{:codename=>"Trauminator", :faction=>"Resistance", :level=>16},
 0=>
  {:portal=>
    {:name=>"\u7D2B\u7AF9\u9AD8\u7E04\u753A\u306E\u304A\u5730\u8535\u69D8",
     :intel=>
      "https://www.ingress.com/intel?ll=35.046226,135.750117&pll=35.046226,135.750117&z=19",
     :photo=>
      "http://lh5.ggpht.com/_o3HB7cK3KKoo8eSFP3vu2JzDtsMR2PCV10WTes07ikHQtYg6aQ0lMnkSGTgeZ5s_7a3CZySpF1gHdwLq8tZ",
     :intel_image=>
      "http://maps.googleapis.com/maps/api/staticmap?center=35.046226,135.750217&zoom=19&size=700x160&style=visibility:on%7Csaturation:-50%7Cinvert_lightness:true%7Chue:0x131c1c&style=feature:water%7Cvisibility:on%7Chue:0x005eff%7Cinvert_lightness:true&style=feature:poi%7Cvisibility:off&style=feature:transit%7Cvisibility:off&markers=icon:http://commondatastorage.googleapis.com/ingress.com/img/map_icons/marker_images/neutral_icon.png%7Cshadow:false%7C35.046226,135.750117&client=gme-nianticinc&signature=zP0rBIFCdPLy2MhIwR6UUPuH82U=",
     :damage=>{:count=>9, :type=>"Link", :date=>"10:00"}},
   :linked_portals=>
    [{:intel=>
       "https://www.ingress.com/intel?ll=35.044485,135.754236&pll=35.044485,135.754236&z=19",
      :name=>
       "\u7D2B\u91CE\u67F3\u516C\u5712 \u53E4\u3073\u305F\u30E9\u30B8\u30AA\u5854",
      :address=>
       "9-1 Koyamashimohatsunecho, Kita Ward, Kyoto, Kyoto Prefecture, Japan"},
     {:intel=>
       "https://www.ingress.com/intel?ll=35.043372,135.750953&pll=35.043372,135.750953&z=19",
      :name=>"Holiness Church",
      :address=>
       "Murasakino Dori, Kita Ward, Kyoto, Kyoto Prefecture 603-8175, Japan"},
     {:intel=>
       "https://www.ingress.com/intel?ll=35.043837,135.748594&pll=35.043837,135.748594&z=19",
      :name=>"\u552F\u660E\u5BFA",
      :address=>
       "Omiya Dori, Kita Ward, Kyoto, Kyoto Prefecture 603-8211, Japan"},
     {:intel=>
       "https://www.ingress.com/intel?ll=35.045297,135.756157&pll=35.045297,135.756157&z=19",
      :name=>
       "\u5C0F\u5C71\u4E0B\u677F\u5009\u753A\u306E\u304A\u5730\u8535\u69D8",
      :address=>
       "Koromonotana Dori, Koyamashimoitakuracho, Kita Ward, Kyoto, Kyoto Prefecture 603-8122, Japan"},
     {:intel=>
       "https://www.ingress.com/intel?ll=35.043170,135.754737&pll=35.043170,135.754737&z=19",
      :name=>
       "\u5C0F\u5C71\u5317\u5927\u91CE\u753A\u306E\u304A\u5730\u8535\u69D8",
      :address=>
       "Shin-machi Dori, Koyamakitaonocho, Kita Ward, Kyoto, Kyoto Prefecture 603-0000, Japan"},
     {:intel=>
       "https://www.ingress.com/intel?ll=35.045417,135.758409&pll=35.045417,135.758409&z=19",
      :name=>"Golden Spikes",
      :address=>
       "49 Koyamakitakamifusach\u014D, Kita-ku, Ky\u014Dto-shi, Ky\u014Dto-fu, Japan"},
     {:intel=>
       "https://www.ingress.com/intel?ll=35.043299,135.746770&pll=35.043299,135.746770&z=19",
      :name=>
       "\u77F3\u4ECF\u9054\u306E\u304A\u5802 \u7D2B\u91CE\u9580\u524D\u753A",
      :address=>
       "Daitokuji Dori, Kita Ward, Kyoto, Kyoto Prefecture 603-8231, Japan"},
     {:intel=>
       "https://www.ingress.com/intel?ll=35.041091,135.746575&pll=35.041091,135.746575&z=19",
      :name=>"\u5927\u5FB3\u5BFA \u5357\u5C71\u9580",
      :address=>
       "85 Murasakino Daitokujich\u014D, Kita-ku, Ky\u014Dto-shi, Ky\u014Dto-fu 603-8231, Japan"},
     {:intel=>
       "https://www.ingress.com/intel?ll=35.044994,135.746711&pll=35.044994,135.746711&z=19",
      :name=>
       "\u5927\u5FB3\u5BFA\u5317\u6771\u306E\u304A\u5730\u8535\u3055\u3093",
      :address=>
       "Daitokuji Dori, Murasakino Daitokujicho, Kita Ward, Kyoto, Kyoto Prefecture 616-0000, Japan"}],
   :attacked_by=>"godiego",
   :status=>{:level=>1, :health=>0, :owner=>"[uncaptured]"}}}
=end