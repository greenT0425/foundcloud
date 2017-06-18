class ArtistsController < ApplicationController
  require 'active_support'
  require 'active_support/core_ext'
  require 'pp'
  require 'faraday'
  
  @@url = 'http://ws.audioscrobbler.com/2.0/'
	@@conn = Faraday.new(url: @@url)

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
    @keyword = params[:keyword]

    if @keyword
    	search_params = {
    	  method: 'artist.search',
    	  artist: @keyword,
    	  limit: 10,
    	  api_key: ENV['LASTFM_API_KEY'],
    	  format: 'json',
    	}    	
    	
    	results = get_search_result(search_params)
    	
      results.each do |result|
      	getInfo_params = {
      	  method: 'artist.getInfo',
      	  artist: result[:name],
      	  api_key: ENV['LASTFM_API_KEY'],
      	  format: 'json',
      	}
      	getTopTracks_params = {
      	  method: 'artist.getTopTracks',
      	  artist: result[:name],
      	  limit:5,
      	  api_key: ENV['LASTFM_API_KEY'],
      	  format: 'json'      	  
      	}
    	  artistInfo = read_artist_info(getInfo_params,getTopTracks_params)
    	  artist = Artist.new(artistInfo)
        @resultArr << artist
      end
    end
    @resultArr = Kaminari.paginate_array(@resultArr).page(params[:page]).per(5)

  end

  def detail
    getInfo_params = {
  	  method: 'artist.getInfo',
  	  mbid: params[:mbid],
  	  api_key: ENV['LASTFM_API_KEY'],
  	  format: 'json',
  	}
  	getTopTracks_params = {
  	  method: 'artist.getTopTracks',
  	  mbid: params[:mbid],
  	  limit:5,
  	  api_key: ENV['LASTFM_API_KEY'],
  	  format: 'json'      	  
  	}
  	artistInfo = read_artist_info(getInfo_params,getTopTracks_params)
    @artist = Artist.new(artistInfo)
  end

  private
  
  def get_search_result(params)
    resultArr = []
    searchData = get_data(params)

    searchDataArr = searchData['results']['artistmatches']['artist']
    searchDataArr.each do |a|
      getInfo_params = {
    	  method: 'artist.getInfo',
    	  artist: a['name'],
    	  api_key: ENV['LASTFM_API_KEY'],
    	  format: 'json',
    	}
    	getTopTracks_params = {
    	  method: 'artist.getTopTracks',
    	  artist: a['name'],
    	  limit:5,
    	  api_key: ENV['LASTFM_API_KEY'],
    	  format: 'json'      	  
    	}
    	resultArr << read_artist_info(getInfo_params,getTopTracks_params)
    end
    return resultArr
  end

  
  def read_artist_info(getInfo_params,getTopTracks_params)
  
    tracks = get_data(getTopTracks_params)
    
    unless tracks['error']
      mainInfo = get_data(getInfo_params)
      
      a_name = mainInfo['artist']['name']
      a_img_s = mainInfo['artist']['image'][2]['#text']
      a_img_l = mainInfo['artist']['image'][3]['#text']
      a_summary = mainInfo['artist']['bio']['summary']
      a_similars = mainInfo['artist']['similar']['artist'].map { |a| a['name'] }
      a_tracks = tracks['toptracks']['track'].map { |a| a['name'] }
      a_mbid = mainInfo['artist']['mbid']
      
      result = {
        name: a_name,
        img_s: a_img_s,
        img_l: a_img_l,
        summary: a_summary,
        similar: a_similars,
        topTracks: a_tracks,
        mbid: a_mbid
      }
    else
      result ={}
    end
    return result
  end

  def get_data(params)
    # Rails.logger.info('test!')

  	response = @@conn.get '', params
  	return JSON.parse(response.body)
  end

end
