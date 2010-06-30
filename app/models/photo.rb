class Photo
  require "open-uri"
  require 'RMagick'
  def self.download url, name
    img = Magick::ImageList.new
    img.from_blob open(url).read
    img.write "tmp/#{name}.png"
    e = Entity.create("id" => "pu/#{CGI.escape(url)}", "url" => name)
    e.add_to_index "photo_name_list", Time.now.to_i
    return name
  end

  def self.clean_cache
    i = 1
    count = 1
    begin
      Entity.paginate("photo_name_list", :page_size => 30000)[0].each do |e|
        system "rm -rf tmp/#{e.url}.png"
        puts "rm -rf tmp/#{e.url}.png #{i}"
        i+= 1
        e.destroy
      end
    rescue => e
      p e
      rescue_id = "pu/#{e.to_s.split("/").pop}"
      Sql.do_sql "delete from indices where entity_id = '#{rescue_id}'"
      if count < 10
        count += 1
        retry
      end
    end
  end
end
