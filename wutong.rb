#coding:utf-8
# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'rubygems'
require 'mechanize'
require 'logger'
require 'mongo'
require 'active_support/all'


$debug=true
logger = Logger.new("wutong.log")
logger.info("Start to grasp!") 
start_time=Time.now
$mongo = Mongo::Connection.new
 puts start_time
    if $debug
      $db = $mongo.db('g0_development')
    else
      $db = $mongo.db('g0_production')
    end
    $col_libcompany=$db[:lib_companies] 
    $company_grasp=$db[:compay_grasps]
    logger.debug "connection Mongodb success!" unless  $mongo.nil? ||$db.nil?  
 total_grasp=0
 valid_grasp=0
 invalid_grasp=0
 repeated_grasp=0
  a = Mechanize.new
  a.set_proxy("wwwgate0-ch.mot.com",1080)
  linkhash =Hash.new
  1.upto(1).each do |i| 

  a.get("http://www.chinawutong.com/101.html?pid=#{i}&f=&t=&cAds=&cN=") do |page|
   # puts page.body.to_s.force_encoding("UTF-8")
   puts "http://www.chinawutong.com/101.html?pid=#{i}&f=&t=&cAds=&cN="
    page.parser.css('a').each do |company|
      if company.to_s.match(/.+\/\d+\/\d+?/)
      company_link=company.attribute("href")
       #puts company_link
      fullLink = "http://www.chinawutong.com#{company_link}"
      #puts fullLink
      linkhash["#{company_link}"] = fullLink
      else
        #puts "company not matched!"
      end
    end
  end
  end
    #puts linkhash
    companylink = Hash.new
    linkhash.each { |key,value| 
    a.get("#{value}") do |page|
        company_index = page.parser.css("div.zxinfo_c")[0].css('a')
         # puts company_index
          comname = company_index.text.to_s.encode('UTF-8')
          comlink =  company_index.attribute("href").to_s
          comlink = comlink.sub(/co.asp/,"co/co4/index.asp")
          
          companylink["#{comlink}"] = comname+"+#{value}"
    end
    }
    
  
    companylink.each { |key,value| 
        companyinfo = Hash.new
        companyinfo["Name"] = value.sub(/\+.*/n,"")
        puts "key"+key
        a.get(key) do |page|
          parentlink = value.sub(/.*\+/n,"")
          puts parentlink
          a.get("#{parentlink}") do |ppage|
          firstone  = "true"
          ppage.parser.css("div.zxinfo_c")[0].css("div.l")[0].css("tr").each do |contactinfo|
            #puts contactinfo.text.to_s
            if(firstone=="true")
              #puts "skip to next!"
                firstone = "false"
                next
            else
              #puts "Not the first one!"
            end
            contact = contactinfo.to_s.encode('UTF-8')
            #logger.info(contact)
            value = contact.to_s.sub(/.*\<td\>/mxi,"").sub(/\<\/td\>.+/mxi,"").sub(/\r+.+/mxi,"")
            keystr = contact.to_s.sub(/：.+/mxi,"").sub(/.+\>/mxi,"")
           
          case keystr
            when "联系人"
            hashkey = "contact"
            when "电  话"
            hashkey = "phone"
            when "手  机"
            hashkey = "mobile"
            when "传  真"
            hashkey = "fax"
            when "地  址"
            hashkey = "addr"
            when "QQ/MSN"
            hashkey = "QQ/MSN"
          else
            logger.info("cannot identify!!")
            next
          end
          #logger.info(key)
            companyinfo["#{hashkey}"] = value.to_s
            #puts "#{key}"+ ":#{value}"
          end
          end
          	email = page.parser.css("tbody tr td span").css('a')[0]
            companyinfo["email"] = email.text
          if companyinfo["email"].nil?
          puts "Invalid grasp!"
          invalid_grasp+=1
          next
          end
          if !companyinfo["email"].match(/.+@.+/)
          logger.info( "Invalid grasp!")
          logger.info("email:#{companyinfo["email"]}")
          invalid_grasp+=1
          next
          end
          puts companyinfo
            logger.info(companyinfo)
             total_grasp+=1
           if $col_libcompany.find({"Name"=>companyinfo["Name"]}).first.nil?
          valid_grasp+=1
          #result=$col_libcompany.insert(companyinfo)
           else
             repeated_grasp+=1
             logger.info("repeated grasp!")
           end
    end    
    }
logger.info("Totally grasped:#{total_grasp}")
logger.info("Totally valid grasped:#{valid_grasp}")
logger.info("Repeated grasped:#{repeated_grasp}")
logger.info("Totally invalid grasped:#{invalid_grasp}")