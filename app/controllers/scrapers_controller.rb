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
  require 'fileutils'
  require 'open-uri'
  require 'pathname'
  #require 'rubygems'
  #require 'scrapi'
  
  def index
    @scrapers = Scraper.all
    
    url = "http://theinfosphere.org/"
    
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
            character_url = nil
            b.search("a").map {|e| character_url = e.get_attribute("href") }
            
            character = (b.search("a").inner_html).strip
            if(character == "")
              character = b.inner_html.strip
            end
            speaker = Speaker.find_by_name(character)
            if(speaker == nil)
                file_name = "Unknown-person.jpg"
                if(character_url != nil)
                img_url = nil
                char_html = Net::HTTP.get(URI.parse("http://theinfosphere.org/#{character_url}"))
                @char_doc = Hpricot(char_html)
                puts "char_html #{character_url}"
                @char_doc.search("//div[@id='image1']") do |img_div|
                  img_url = nil
                  puts "img_div #{img_div}"
                  img_div.search("img").map {|e| img_url = e.get_attribute("src") }
                end
                if(img_url!= nil && !img_url.empty?)
                  path = Pathname.new(img_url)  
                  if not path.relative? then img_url = url + img_url end
                  open(img_url) do |source|
                    file_name = img_url.split('/').last
                    open("images" + '/' + file_name, 'wb') {|file| file.write(source.read())}
                  end
                end
              end
              speaker = Speaker.new(:name => character, :image_path => file_name)
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
    
    process_words
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @scrapers }
    end
  end

  def process_exchanges
    @sentences = Sentence.all
    puts "got sentences"
    
    id1 = nil
    id2 = nil
    count = 0
    @sentences.each do |s|
      id1 = id2
      id2 = s.speaker_id
      
      if(!id1.nil? && !id2.nil?)
        exchange = Exchange.find_by_id1_and_id2(id1, id2)
        
        if(count % 10 == 0)
          puts count
        end
        count = count + 1
        if(exchange.nil?)
          ex1 = Exchange.new(:id1 => id1, :id2 => id2, :count => 1)
          ex1.save
          if(id1 != id2)
            ex2 = Exchange.new(:id1 => id2, :id2 => id1, :count => 1)
            ex2.save
          end
        else
          exchange.count = exchange.count + 1
          exchange.save
          if(id1 != id2)
            exchange = Exchange.find_by_id1_and_id2(id2, id1)
            exchange.count = exchange.count + 1
            exchange.save
          end
        end
        
      end
    end
  end

  def process_words
    puts "in process words"
    @sentences = Sentence.all
    puts "got sentences"
    
    @sentences.each do |s|
      sentence = s.sentence
      words = sentence.split(/[^a-zA-Z]/)
      
      words.each do |w|
        w = w.capitalize
        if (!w.empty?)
          word = Word.find_by_word(w)
          if(word == nil)
            word = Word.new(:word => w)
            word.save
            count = Count.new(:word_id => word.id, :episode_id => s.episode_id, :speaker_id => s.speaker_id, :count => 1)
            count.save
          else
            pp s
            c = Count.find_by_word_id_and_episode_id_and_speaker_id(word.id, s.episode_id, s.speaker_id)
            if(c.nil?)
              c = Count.new(:word_id => word.id, :episode_id => s.episode_id, :speaker_id => s.speaker_id, :count => 1)
            else
              c.count = c.count + 1  
            end
            #Rails.logger = Logger.new(STDOUT)
            #logger.debug "Person attributes hash: #sentence hash: #{s}, word id: #{word.id}, ep_id: #{s.episode_id}, sp_id: #{s.speaker_id}"
            #c = Count.find_by_word_id_and_episode_id_and_speaker_id(:word_id => word.id, :episode_id => s.episode_id, :speaker_id => s.speaker_id)
            #puts "#{c.episode_id}"
            c.save
          end
        end
      end
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