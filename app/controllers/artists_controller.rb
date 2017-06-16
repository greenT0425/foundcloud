class ArtistsController < ApplicationController

	require 'active_support'
	require 'active_support/core_ext'
	require 'pp'
	require 'faraday'
	

  def index
    
    # サンプルデータ
    serarchArr = [
      'Maco Marets',
      'stuts',
      'cero',
      'charisma.com',
      'LUCKY TAPES',
      'EVISBEATS',
      'Suchmos',
      'フレンズ',
      'Predawn',
      'Nulbarich']
      
    resultArr = []
      
    serarchArr.each do |a|
      mainInfo = get_artist_info(a)
      tracks = get_artist_tracks(a)
      
      a_name = mainInfo['artist']['name']
      a_img = mainInfo['artist']['image'][3]['#text']
      a_similars = mainInfo['artist']['similar']['artist'].map { |a| a['name'] }
      a_tracks = tracks['toptracks']['track'].map { |a| a['name'] }
      
      resultArr << {
        name: a_name,
        img: a_img,
        tracks: a_tracks,
        similars: a_similars
      }
    end
    
    @resultArr = Kaminari.paginate_array(resultArr).page(params[:page]).per(10)

  end

  def get_artist_info(name)
    url = 'http://ws.audioscrobbler.com/2.0/'
  	conn = Faraday.new(url: url)
  	
  	params = {
  	  method: 'artist.getinfo',
  	  artist: name,
  	  api_key: ENV['LASTFM_API_KEY'],
  	  format: 'json',
  	}
  	
  	response = conn.get '', params
  	response_json = JSON.parse(response.body)
  	response_json
  end
  
  def get_artist_tracks(name)
    url = 'http://ws.audioscrobbler.com/2.0/'
  	conn = Faraday.new(url: url)
  	
  	params = {
  	  method: 'artist.getTopTracks',
  	  artist: name,
  	  api_key: ENV['LASTFM_API_KEY'],
  	  format: 'json',
  	}
  	
  	response = conn.get '', params
  	response_json = JSON.parse(response.body)
  	response_json
  end

end
