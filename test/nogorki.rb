require 'open-uri'
require 'nokogiri'
require 'httparty'
require 'loofah'

doc = Nokogiri::HTML(URI.open('http://www.threescompany.com/'))
# puts doc

response = HTTParty.get('http://www.threescompany.com/')
html = response.body

doc = Nokogiri::HTML(html)

doc.css('head, metadata, script, style, footer, nav, comment, .ads, .sidebar').remove
doc.xpath('//comment()').remove
# clean_content = Loofah.fragment(doc.to_html).scrub!(:prune).to_text
# clean_content.gsub('&#13;', '').gsub(/\n{2,}/, "\n\n").strip

puts doc
