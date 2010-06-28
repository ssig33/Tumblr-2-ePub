class Tumblr
  require 'open-uri'
  require 'xmlsimple'
  require 'eeepub'
  require 'thread'

  def self.runner
    begin
      while true  
        count = 0
        begin
          Entity.paginate("crawl_list", :page_size => 100)[0].each do |e|
            puts "PROCESS #{e.target}.tumblr.com"
            name = create_epub(get_posts(e.target, 50))
            if name != nil and name != ""
              post = Entity.create("name" => name, "created_at" => Time.now.to_i, "target" => e.target)
              post.add_to_index "epubs/#{e.target}", Time.now.to_i
              post.add_to_index "epubs_public", Time.now.to_i
            end
            e.destroy
          end
          sleep 3
        rescue => e
          rescue_id = "job/crawl/#{e.to_s.split("/").pop}"
          Sql.do_sql "delete from indices where entity_id = '#{rescue_id}'"
          if count < 10
            count += 1
            retry
          end
        end
      end
    rescue
      retry
    end
  end

  def self.get_posts id, count
    count = count.to_i
    begin
      hash = {}
      array = []
      i = 0
      while true
        xml = XmlSimple.xml_in(open("http://#{id}.tumblr.com/api/read?num=50&start=#{(i*50)+1}").read, {'ForceArray' => false})
        hash["tumblelog"] = xml["tumblelog"]  if i == 0
        xml["posts"]["post"].each do |k|
          array << k
        end
        i += 1
        break if xml["posts"]["post"].size < 50 or array.size >= count
      end
      hash["posts"] = array
      return hash
    rescue
    end
  end

  def self.create_epub tumble
    begin
    @photos = []
    @downloads = []
    pages = []
    tumble["posts"].each do |p|
      pages << process_post(p)
    end
    @threads = []
    @downloads.each do |p|
      @threads << Thread.start do
        i = 0
        begin
          Photo.download p[1], p[0]
        rescue
          i += 1
          retry if i < 10
        end
      end
    end
    @threads.each{|thread| thread.join}
    e = EeePub::Easy.new do
      title tumble["tumblelog"]["title"]
      creator tumble["tumblelog"]["name"]
      identifier "http://#{tumble["tumblelog"]["name"]}.tumblr.com", :scheme => 'URL'
      uid "http://#{tumble["tumblelog"]["name"]}.tumblr.com"
    end
    @photos.each do |p|
      begin
        open("/users/ssig33/dev/tumblr2epub/tmp/#{p}.png").read
        e.assets << "/users/ssig33/dev/tumblr2epub/tmp/#{p}.png"
      rescue Errno::ENOENT
      end
    end
    pages.each do |page|
      if page != nil
        e.sections << ["tumblr", 
<<HTML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja">
  <head>
      <title>Tumblr</title>
  </head>
  <body>
    #{page_to_html page}
  </body>
</html>
HTML
        ]
      end
    end
    
    filename = rand(256**16).to_s(16)
    e.save "public/#{filename}.epub"
    return "#{filename}.epub"
    rescue => e
      puts "Rescue create epub"
      p e
    end
  end

  def self.process_post post
    if post["type"] == "quote"
      return {:title => post["quote-source"], :text => post["quote-text"]}
    elsif post["type"] == "photo"
      post["photo-url"].each do |u|
        if u["max-width"] == "500"
          begin
            e = Entity.find("pu/#{CGI.escape(u["content"])}")
            @photos << e.url
            @text = "<div style='max-height:90%'><img src='#{e.url}.png' /></div>"
          rescue
            name = rand(256**16).to_s(16)
            @downloads << [name,u["content"]]
            @photos << name
            @text = "<div style='max-height:90%'><img src='#{name}.png' /></div>"
          end
        end
      end
      return {:title => nil, :text => @text}
    elsif post["type"] == "regular"
      return {:title => "<a href='#{post["url"]}'>#{post["regular-title"]}</a>", :text => post["regular-body"]}
    else 
      return nil
    end
  end

  def self.page_to_html page
    return "<h3>#{page[:title]}</h3><p>#{page[:text]}</p>\n" if page[:title]
    return "#{page[:text]}\n" unless page[:title]
  end
end
