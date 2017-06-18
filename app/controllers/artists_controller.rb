class ArtistsController < ApplicationController
  require 'active_support'
  require 'active_support/core_ext'
  require 'pp'
  require 'faraday'

  def index
    @resultArr = []
    
    # サンプルデータ
    results = ['Maco Marets','stuts','cero','charisma.com','LUCKY TAPES','EVISBEATS','Suchmos','フレンズ','Predawn','Nulbarich']

    results.each do |result|
      artist = Artist.new(read_artist_info(result))
      @resultArr << artist
    end
    
    @resultArr = Kaminari.paginate_array(@resultArr).page(params[:page]).per(5)

  end


  def search
    @resultArr = []

    # サンプルデータ
    # @keyword = 'never young beach'  
    @keyword = params[:keyword]
    
    if @keyword
      results = get_search_result(@keyword)
      results.each do |result|
        artist = Artist.new(read_artist_info(result[:name]))
        @resultArr << artist
      end
    end
    @resultArr = Kaminari.paginate_array(@resultArr).page(params[:page]).per(5)

  end


  private
  
  def get_search_result(keyword)
    resultArr = []
    searchData = get_data('search',keyword)
    searchDataArr = searchData['results']['artistmatches']['artist']
    searchDataArr.each do |a|
      resultArr << read_artist_info(a['name'])
    end
    return resultArr
  end

  
  def read_artist_info(searchWord)
  
    tracks = get_data('getTopTracks',searchWord)
    
    unless tracks['error']
      mainInfo = get_data('getinfo',searchWord)
      a_name = mainInfo['artist']['name']
      a_img_s = mainInfo['artist']['image'][2]['#text']
      a_img_l = mainInfo['artist']['image'][3]['#text']
      a_summary = mainInfo['artist']['bio']['summary']
      a_similars = mainInfo['artist']['similar']['artist'].map { |a| a['name'] }
      a_tracks = tracks['toptracks']['track'].map { |a| a['name'] }
      
      result = {
        name: a_name,
        img_s: a_img_s,
        img_l: a_img_l,
        summary: a_summary,
        similar: a_similars,
        topTracks: a_tracks
      }
    else
      result ={}
    end
    return result
  end

  def get_data(method,name)
    Rails.logger.info('test!')
    url = 'http://ws.audioscrobbler.com/2.0/'
  	conn = Faraday.new(url: url)
  	
  	params = {
  	  method: 'artist.' + method,
  	  artist: name,
  	  limit: 7,
  	  api_key: ENV['LASTFM_API_KEY'],
  	  format: 'json',
  	}
  	
  	response = conn.get '', params
  	return JSON.parse(response.body)
  end

end
