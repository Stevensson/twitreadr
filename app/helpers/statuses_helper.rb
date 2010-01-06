#for Martins part
require 'net/http'
require 'uri'
require 'youtube_g'
require 'bitly'
require 'rubygems'
require 'nokogiri'
require 'open-uri'

module StatusesHelper

  def linkup_mentions(text)    
    text.gsub!(/@([\w]+)(\W)?/, '@<a href="/users/\1">\1</a>\2')
    text
  end
  
  def pretty_datetime(datetime)
    date = datetime.strftime('%b %e, %Y').downcase
    time = datetime.strftime('%l:%M%p').downcase
    content_tag(:span, date, :class => 'date') + " " + content_tag(:span, time, :class => 'time')
  end




# here starts Martins part of the code...


  def purgeurl(statustext)
   url = isolate_link(statustext)
   purged_url = get_deshortened_url(url)
   purged_url
  end 

  def place_vid_emb(statustext)
    a = get_vid_embed(purged_url)
    a.to_s
  end

  def has_weblink(statustext)
    if statustext.match /(http:\/\/)/
      TRUE
    else
      FALSE
    end
  end

  #
  #
  #
  # -------------- here the video methods

  def is_video_site(statustext)
    url = isolate_link(statustext)
    theurl = get_deshortened_url(url).to_s
    if theurl.match /(http:\/\/www\.youtube\.com\/watch\?v\=(\w*))/
      TRUE
    else
      FALSE
    end
  end

  def get_vid_embed(statustext)
      yt = statustext.match /(http:\/\/www\.youtube\.com\/watch\?v\=(\w*))/
      yt_vid = yt[2]
      youtube_client = YouTubeG::Client.new
      the_vid = youtube_client.video_by(yt_vid)
      vid_html = the_vid.embed_html
      vid_html
  end

  #
  # -------------- here the image methods (NOT YET DONE)


  #
  # -------------- end image
  #



  #
  # -------------- here are the URL methods


  def create_weblink_img_url(statustext)
    # creates URL to be placed in image tag for display of site preview
    url = statustext
    imgurl = ""
    if url.match /(http:\/\/www\.)/
      shortlink = url.sub(/(http:\/\/www\.)/, "")
      imgurl = "http://www.shrinktheweb.com/xino.php?embed=1&STWAccessKeyId=f702c5b047bec2b&Size=lg&stwUrl=#{shortlink}"
    else
      shortlink = url.sub(/(http:\/\/)/, "")
      imgurl = "http://www.shrinktheweb.com/xino.php?embed=1&STWAccessKeyId=f702c5b047bec2b&Size=lg&stwUrl=#{shortlink}"
    end
    imgurl
  end

  def extract_weblink_text(statustext)
    url = statustext
    doc = Nokogiri::HTML(open(url))
    posts = doc.at_css('p')
    t = posts.to_s
    f = t.gsub(/<\/?[^>]*>/, "") 
    g = f
    g
  end
  
  def extract_weblink_title(statustext)
    url = statustext
    doc = Nokogiri::HTML(open(url))
    posts = doc.at_css("title")
    weblink_title = posts.text
    weblink_title
  end

  def extract_weblink_metasecr(statustext)
    weblink_metadescription = ""
    url = statustext
    doc = Nokogiri::HTML(open(url))
    posts = doc.xpath("//meta")
      posts.each do |link|
          a = link.attributes['name']
          b = link.attributes['content']
            if a.to_s == 'description'
              weblink_metadescription = b.to_s 
            end 
      end
    weblink_metadescription
  end

  def isolate_link(statustext) 
    # works, but currently only for one link. More links will be complex.. 
    a = URI.extract(statustext)
    b = []
    a.each do |test|
        if test.match /(http:\/\/)/
          b << test
        end 
    end
    c = b[0]
    c.to_s
  end

  #
  # -------------- end url
  #


  #
  # -------------- here are the other helper methods
  
  
  def get_deshortened_url(isourl)
    #works
    if is_shortened(isourl)
      url = deshorten(isourl)
    else
      url = isourl
    end
    url
  end


  def is_shortened(isourl)
    #works
    case isourl
      when /(http:\/\/bit\.ly\/\w*)/
        TRUE
      when /(http:\/\/tcrn\.ch\/\w*)/
       TRUE
      else
       FALSE
    end
  end

  def deshorten(isourl)
    #works
    expanded_url = ""
    case isourl
      when /(http:\/\/bit\.ly\/\w*)/
        bt = isourl.match /(http:\/\/bit\.ly\/\w*)/
        bt_vid = bt[0]
        bitly = Bitly.new('martinhuegli', 'R_27da938c6864ede12230847cf35fd0ea')
        expanded_url = bitly.expand(bt_vid).long_url
      when /(http:\/\/tcrn\.ch\/\w*)/
        bt = isourl.match /(http:\/\/tcrn\.ch\/\w*)/
        bt_vid = bt[0]
        bitly = Bitly.new('martinhuegli', 'R_27da938c6864ede12230847cf35fd0ea')
        expanded_url = bitly.expand(bt_vid).long_url
    end
    expanded_url
  end


end
