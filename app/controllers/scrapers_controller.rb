class ScrapersController < ApplicationController
  # GET /scrapers
  # GET /scrapers.xml
  
  require 'net/http'
  require 'uri'
  require 'rubygems'
# use 'gem install hpricot --source code.whytheluckystiff.net'
# to install hpricot
  require 'hpricot'
  require 'tactful_tokenizer'
  require 'pp'
  
  def index
    @scrapers = Scraper.all

    #html = Net::HTTP.get(URI.parse('file:///C:/Users/Yuriy/Desktop/Futurama%20Transcripts/Futurama%20Transcripts/Season%201/Transcript%20A_Big_Piece_of_Garbage.htm'))
    html = IO.read("C:/Users/Yuriy/Desktop/Futurama Transcripts/Futurama Transcripts/Season 1/Transcript A_Big_Piece_of_Garbage.htm") 
    
    @doc = Hpricot(html)
    
    @doc.search("//div[@class='poem']") do |div|
      
      div.search("//a") do |a|
        character = (a.inner_html).strip
        speaker = Speaker.find_by_name(character)
        if(speaker == nil)
          speaker = Speaker.new(:name => character)
          speaker.save
        end
      end
      
      div.search("//p") do |p|
        p.search("b").remove
        text = p.inner_html
        text = text[1, text.size]
        text = text.strip
        puts text.count_words
        tokenizer = Punkt::SentenceTokenizer.new(text)
        result    = tokenizer.sentences_from_text(text, :output => :sentences_text)
        pp result
      end
      break
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @scrapers }
    end
  end

  # GET /scrapers/1
  # GET /scrapers/1.xml
  def show
    @scraper = Scraper.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @scraper }
    end
  end

  # GET /scrapers/new
  # GET /scrapers/new.xml
  def new
    @scraper = Scraper.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @scraper }
    end
  end

  # GET /scrapers/1/edit
  def edit
    @scraper = Scraper.find(params[:id])
  end

  # POST /scrapers
  # POST /scrapers.xml
  def create
    @scraper = Scraper.new(params[:scraper])

    respond_to do |format|
      if @scraper.save
        format.html { redirect_to(@scraper, :notice => 'Scraper was successfully created.') }
        format.xml  { render :xml => @scraper, :status => :created, :location => @scraper }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @scraper.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /scrapers/1
  # PUT /scrapers/1.xml
  def update
    @scraper = Scraper.find(params[:id])

    respond_to do |format|
      if @scraper.update_attributes(params[:scraper])
        format.html { redirect_to(@scraper, :notice => 'Scraper was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @scraper.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /scrapers/1
  # DELETE /scrapers/1.xml
  def destroy
    @scraper = Scraper.find(params[:id])
    @scraper.destroy

    respond_to do |format|
      format.html { redirect_to(scrapers_url) }
      format.xml  { head :ok }
    end
  end
end

class String
  def count_words
    n = 0
    scan(/\b\S+\b/) { n += 1}
    n
  end 
end