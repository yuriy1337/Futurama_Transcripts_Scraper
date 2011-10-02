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
    
    for season in (1..6)
      
      episode = 1
      
      Dir.foreach("C:/Users/Yuriy/Desktop/Futurama Transcripts/Futurama Transcripts/Season #{season}") do |file|
        
        if(file == '.' || file == '..')
          next
        end
        
        ep = Episode.new(:episode => episode, :season => season)
        ep.save
        
        puts "ep #{episode} season #{season}"
        
        html = IO.read("C:/Users/Yuriy/Desktop/Futurama Transcripts/Futurama Transcripts/Season #{season}/#{file}") 
        
        @doc = Hpricot(html)
        @doc.search("//div[@class='poem']") do |div|
          
          speaker_id = 0
          
          div.search("span").remove
          
          div.search("//b") do |b|
            character = (b.search("a").inner_html).strip
            if(character == "")
              character = b.inner_html.strip
            end
            speaker = Speaker.find_by_name(character)
            if(speaker == nil)
              speaker = Speaker.new(:name => character)
              speaker.save
            end
            speaker_id = speaker.id
          end
          
          div.search("//p") do |p|
            p.search("b").remove
            p.search("i").remove
            p.search("br").remove
            text = ""
            #puts p
            p.search("a") do |a|
              text = a.inner_html
              p.at("a").swap("#{text}")
            end
            text = p.inner_html
            text = text[1, text.size]
            if(text != nil && text != "" && !text.empty?)
            text = text.strip
              if(text != nil && text != "" && !text.empty?)
              text = text.gsub(/\[(.*?)\]/, '')
              text = text.gsub(/\((.*?)\)/, '')
                if(text != nil && text != "" && !text.empty?)
                  text = text.strip
                  tokenizer = Punkt::SentenceTokenizer.new(text)
                  result    = tokenizer.sentences_from_text(text, :output => :sentences_text)
                  if(result != nil)
                    result.each do |sent|
                      word_count = sent.count_words
                      letter_count = sent.count('A-z')
                      sentence = Sentence.new(:speaker_id => speaker_id, :episode_id => ep.id, :sentence => sent.strip, :num_of_words => word_count, :num_of_chars => letter_count)
                      sentence.save
                    end
                  end
                end
              end
            end
          end
        end
        episode = episode + 1 
      end
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