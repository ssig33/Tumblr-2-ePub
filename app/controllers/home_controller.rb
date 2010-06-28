class HomeController < ApplicationController
  def index
  end

  def go
    redirect_to :action => :view, :id => params[:tumblr_id]
  end

  def view
    @epubs ,@pager = Entity.paginate("epubs/#{params[:id]}")
    begin
      @job = Entity.find "job/crawl/#{params[:id]}"
    rescue
      if (@epubs.size > 0 and (Time.now.to_i - @epubs[0].created_at) > 5400) or @epubs.size == 0
        e = Entity.create("id" => "job/crawl/#{params[:id]}", "target" => params[:id])
        e.add_to_index("crawl_list", Time.now.to_i)
        @job = true
      end
    end
  end

  def list
    @epubs = Entity.paginate("epubs_public", :page_size => 100)[0]
    respond_to do |format|
      format.html
      format.atom
    end
  end
end
