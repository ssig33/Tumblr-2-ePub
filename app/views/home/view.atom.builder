atom_feed do |feed|
  feed.title "Tumblr 2 ePub #{params[:id]} PodCast"
  feed.updated Time.at(@epubs.first.created_at)

  @epubs.each do |t|
    feed.entry(t, :url => "http://tumblr2epub.ssig33.com/view/#{params[:id]}", :updated => Time.at(t.created_at)) do |entry|
      entry.title h "#{params[:id]}.tumblr.com @ #{Time.at(t.created_at)}"
      entry.updated Time.at(t.created_at).rfc822
      entry.published Time.at(t.created_at).rfc822
      entry.content "", :type => "html"
      entry.link({:rel => "enclosure", :title => "ePub", :type => "application/epub+zip", :href => "http://tumblr2epub.ssig33.com/#{t.name}"})
      entry.author do |a|
        a.name params[:id]
      end
    end
  end
end
