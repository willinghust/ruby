#coding:utf-8
# To change this template, choose Tools | Templates
# and open the template in the editor.

#  To change this template, choose Tools | Templates
# and open the template in the editor.

require 'rubygems'
require 'mechanize'
require 'logger'


def search(link,key,inforegex,pageregex,component1,component2)
agent = Mechanize.new
#agent.set_proxy("wwwgate0-ch.mot.com",1080)
page = agent.get(link)
case link
when /bing/
  puts "bing!"
  search_form = page.form_with(:id => component1)
when /yahoo/
  puts "yahoo!"
  search_form = page.form_with(:id => component1)
else
  puts link
  search_form = page.form_with(:name => component1)
end
search_form.field_with(:name => component2).value = key
search_results = agent.submit(search_form)
#first page
link_hash = Hash.new
#link_array = []
qq_array = []
search_results.body.scan(Regexp.new(inforegex,Regexp::MULTILINE | Regexp::IGNORECASE | Regexp::EXTENDED)).each do |qq|
   qq_array << qq.to_s.gsub(/\D/,"")
 end
 search_results.parser.css('a').each do |blink|
  full = link + blink.attribute("href").to_s
  #puts full
 pageindex = full.match(Regexp.new(pageregex,Regexp::MULTILINE | Regexp::IGNORECASE | Regexp::EXTENDED))
 if !pageindex.nil?
   link_hash [pageindex.to_s.gsub(/\D/,"")] = full
   #link_array << full
 end
 end
#other pages
  usinglink = ""
  1.upto(50).each do |i|
  usinglink =   link_hash[i]
  puts "Start grasp page #{i}"
  count = 0
  puts usinglink
  page = agent.get(usinglink)
  page.parser.css('a').each do |blink|
   full = link + blink.attribute("href").to_s
  pageindex = full.match(Regexp.new(pageregex,Regexp::MULTILINE | Regexp::IGNORECASE | Regexp::EXTENDED))
  if !pageindex.nil?
   if !link_hash.has_key?(pageindex.to_s.gsub(/\D/,""))
   puts "add !!!"
   link_hash [pageindex.to_s.gsub(/\D/,"")] = full
   #link_array << full
  end
  end
  end
  page.body.scan(Regexp.new(inforegex,Regexp::MULTILINE | Regexp::IGNORECASE | Regexp::EXTENDED)).each do |qq|
     qq_array << qq.to_s.gsub(/\D/,"")
     count+=1
  end
  puts "caught:#{count}"
  end
  puts link_hash
puts qq_array.uniq!
end

def grasp_qq(eginelink,keyword,regex)
  case eginelink
  when /baidu/
    search(eginelink,keyword,regex,"&pn=\\d+","f","wd")
  when /sogou/
    search(eginelink,keyword,regex,"&page=\\d+","sf","query")
  when /google/
    search(eginelink,keyword,regex,"&start=\\d+","f","q")
  when /bing/
    search(eginelink,keyword,regex,"&first=\\d+&FORM=PERE","sb_form","q")
  when /yahoo/
    search(eginelink,keyword,regex,"&pstart=1&b=\\d+","sf","p")
  else
    puts "Unsurppored engine!"
  end
end

grasp_qq("http://www.google.com","物流专线 qq","[qQ][qQ].{5,10}[1-9]\\d{5,9}?")
