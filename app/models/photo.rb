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
end
