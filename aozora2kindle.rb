require 'rubygems'
require 'nokogiri'
require 'open-uri'

def wget(url)
  f = File.basename(url)
  return if File.exist?(f)
  open(f, 'wb') do |file|
    open(url) do |data|
      file.write(data.read)
    end
  end
end

def fetch_css
  return if File.exist?('aozora.css')
  wget('http://www.aozora.gr.jp/cards/aozora.css')
  new_css = "html {-webkit-writing-mode: vertical-rl;}\n"
  File.open('aozora.css', 'r') do |f|
    f.each do |line|
      if url = line.match(/url\("(.*)"\)/) then
        wget('http://www.aozora.gr.jp/cards/' + url[1])
    	line = line.sub(url[1], File.basename(url[1]))
      end
      new_css += line
    end
  end
  File.open('aozora.css', 'w') do |f|
    f.write(new_css)
  end
end

def download_images(doc)
  doc.css("img").each do |e|
    src = e['src']
    src[0..8] = 'http://www.aozora.gr.jp/'
    wget(src)
  end
end

def convert_html!(doc)
  doc.css("link").each do |link|
    if link["rel"] == "stylesheet" then
      link["href"] = File.basename(link["href"])
    end
  end
  doc.css("img").each do |img|
    img['src'] = File.basename(img['src']) 
  end
end

def fetch_html(url)
  wget(url)
  new_html = ''
  File.open(File.basename(url), 'r') do |f|
    doc = Nokogiri::HTML(f)
    download_images(doc)
    convert_html!(doc)  
    new_html = doc.to_html
  end
  File.open(File.basename(url), 'w') do |f|
    f.write new_html
  end
end

if ARGV.length < 1 then
  abort('usage: ruby xhtml2mobi.rb <url of aozora bunko xhtml>')
end
fetch_css()
fetch_html(ARGV[0])

