require 'dotenv'
require 'rspotify'
require 'sinatra'

Dotenv.load
RSpotify.authenticate(ENV['CLIENT_ID'], ENV['CLIENT_SECRET'])
use Rack::Session::Cookie
use OmniAuth::Builder do
  provider :spotify, ENV['CLIENT_ID'], ENV['CLIENT_SECRET'], scope: 'playlist-read-private user-follow-modify'
end

get '/auth/spotify/callback' do
  user = RSpotify::User.new(request.env['omniauth.auth'])

  playlist = RSpotify::Playlist.find('h13ronim', '1eLvx2KoXGkwxf06ok0IWb')

  playlist.tracks.each do |track|
    puts "track: #{track.name}"
    track.artists.each do |artist|
      puts "artist: #{artist.name}"
      begin
        user.follow(artist)
      rescue RestClient::ResourceNotFound => e
        puts '==='
        puts 'Error: RestClient::ResourceNotFound'
        puts e.response
        puts '==='
      end
    end
    puts "---"
  end

  'DONE.'
end

get '/' do
  '<a href="/auth/spotify">Follow</a>'
end
