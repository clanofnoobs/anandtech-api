class ArticlesController < ApplicationController
  before_filter :get_articles, :only => :articles 
  require 'open-uri'
  def articles
    @articles = {:articles => @all_articles, :featured_articles => @featured_articles }
    render :json => @articles
  end

  private

  def get_articles
    require 'open-uri'
    
    @featured_articles = []

    doc = Nokogiri::HTML(open("http://anandtech.com"))

    @all_articles = Rails.cache.fetch("anandtech/articles", :expires_in => 5.minute) do 
      scrape_articles(doc)
    end
    @all_articles.each do |article|
      if article[:featured]
        @featured_articles << article 
      end
    end
    @all_articles.select!{ |k| k if !k[:featured] }
  end

  def scrape_articles(doc)
    
    @data = []

    doc.css(".l_").each do |article_container|
      article_title = article_container.css("h2").text
      source = article_container.css("a").attr("href").text
    
      temp_cell = { :title => article_title, :link => source }
    @data << temp_cell
    end
    #featured stories
    doc.css(".hide_resp2 .b").each do |author|
    end

    doc.css(".hide_resp2 h2 a , .featured_info h2").each do |featured_title|
      source = featured_title.attr("href")
      tempCell = { :title => featured_title.text, :featured => "true" }
      @data << tempCell
    end
    @data
  end
end
