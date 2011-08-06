#coding:utf-8
# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'rubygems'
require 'mechanize'
require 'logger'
require 'mongo'
require 'active_support/all'

$debug=true
logger = Logger.new("dx565.log")
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
  #a.set_proxy("wwwgate0-ch.mot.com",1080)

   6.upto(7).each do |i| 
     link = "http://qiye.xd565.com/p0_c0_t0/Cata14/Page_#{i}"
     
    a.get(link) do |page|
    page.parser.css("dl dd").each do |company|
      cominfo = company.css('a')[0]
      comlink = cominfo.attribute("href").to_s
      if comlink.match(/Cata\d+_q+\d+/)
        companyinfo =Hash.new
        comname  = cominfo.text
        companyinfo["Name"] = comname
        companyinfo["email"] = company.css('li')[0].text.to_s.sub(/.+电子邮箱：/mxi,"")
        if !companyinfo["email"].match(/.+@.+/)
          logger.info( "Invalid grasp!")
          logger.info("email:#{companyinfo["email"]}")
          invalid_grasp+=1
          next
        end
        if companyinfo["email"].nil?
          puts "Invalid grasp!"
          invalid_grasp+=1
        end

        puts comlink.chop!
        a.get(comlink) do |comdetails|
          comdetails.parser.css('tr').each do |contactinfo|
          #puts contactinfo
            item = contactinfo.css('td')[0].text.to_s.sub(/：/mxi,"")
          puts item
          case item
          when "联系人"
            companyinfo["contact"] = contactinfo.css('td')[1].text
          when "传真"
            companyinfo["fax"] = contactinfo.css('td')[1].text
          when "联系电话"
            companyinfo["phone"] = contactinfo.css('td')[1].text
          when "手机"
            companyinfo["mobile"] = contactinfo.css('td')[1].text
          when "地址"
            companyinfo["addr"] = contactinfo.css('td')[1].text
          else
            next
          end
          end
        end
          logger.info(companyinfo)
          total_grasp+=1
          if $col_libcompany.find({"Name"=>companyinfo["Name"]}).first.nil?
          valid_grasp+=1
          $col_libcompany.insert(companyinfo)
           else
             repeated_grasp+=1
           end
      end
    end 
     
   end
   end
logger.info("Totally grasped:#{total_grasp}")
logger.info("Totally valid grasped:#{valid_grasp}")
logger.info("Repeated grasped:#{repeated_grasp}")
logger.info("Totally invalid grasped:#{invalid_grasp}")
