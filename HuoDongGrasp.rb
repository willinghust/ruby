# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'rubygems'
require 'mechanize'
require 'logger'

$debug=true
logger = Logger.new("dx565.log")
logger.info("Start to grasp!") 
start_time=Time.now
puts start_time

 total_grasp=0
 valid_grasp=0
 invalid_grasp=0
 repeated_grasp=0
 a = Mechanize.new
 url = "http://event.mosh.cn/hangzhou/"
 a.get(url) do |page| 
   page.parser.css("select").css("option").each do |city|
     cityname = city.text.to_s
     cityurl = city.to_s.sub(/.+="/,"").sub(/".+/,"").sub(/\n/,"")
     if(cityurl.match(/beijing|xuzhou/))
       next
     end
    logger.info("Start grasp city :"+cityname.encode('UTF-8')) 
    logger.info("City Url :" + cityurl.encode('UTF-8')) 
    a.get(cityurl) do |page| 
    page.parser.css("ul")[1].css('a').each do |activity|
      activity_link =activity.attribute("href")
      logger.info("Start to grasp " + activity.text.to_s)
      a.get(activity_link) do |pg| 
        pg.parser.css("dl").each do |item|
        name = item.css('dt').css('a')
        logger.info(name.text.to_s.encode('UTF-8')) 
        content = item.css('dd')
        if (content.size > 3)
        logger.info(content[0].text.to_s.encode('UTF-8')) 
        logger.info(content[1].text.to_s.encode('UTF-8')) 
        logger.info(content[2].text.to_s.encode('UTF-8')) 
        end
          item_link = name.attribute("href")
          puts item_link
          a.get(item_link) do |detail| 
            details = detail.parser.css("div.fix")[0].css('p')
            puts details
            logger.info("»î¶¯ÄÚÈİ£º"+details.to_s) 
          end
      end
    end
    end
    end
    end
 end