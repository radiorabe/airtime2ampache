# common boilerplate
$:.unshift File.dirname(__FILE__)
require 'common'

# models for doing foreign key lookups and validation in screens
require 'album'
require 'artist'
require 'song'
require 'catalog'

pre_process do
  # work around https://github.com/activewarehouse/activewarehouse-etl/issues/32
  ActiveRecord::Base.establish_connection :airtime
end

source :default, {
  :type       => :database,
  :target     => :airtime,
  :query      => '
    SELECT
      track_title,
      filepath,
      album_title,
      artist_name,
      COALESCE(year, \'0\') AS year,
      bit_rate,
      sample_rate,
      length,
      track_number
    FROM cc_files
  '
}

rename :track_title,  :title
rename :filepath,     :file
rename :album_title,  :album
rename :artist_name,  :artist
rename :bit_rate,     :bitrate
rename :sample_rate,  :rate
rename :length,       :time
rename :track_number, :track

transform :album, :foreign_key_lookup, {
  :resolver => ActiveRecordResolver.new(
    Album, :find_id_by_name
  ),
  :default  => 0
}
transform :artist, :foreign_key_lookup, {
  :resolver => ActiveRecordResolver.new(
    Artist, :find_id_by_name
  ),
  :default  => 0
}

transform :year, :type, :type => :number

transform(:time) do |key, value, row|
  hours, minutes, seconds = value.split(':').map(&:to_i)
  (hours * 60 * 60) + (minutes * 60) + seconds
end

destination :out, {
  :type     => :database,
  :target   => :ampache,
  :truncate => true,
  :table    => 'song'
},
{
  :order   => [
    :title,
    :file,
    :album,
    :artist,
    :bitrate,
    :rate,
    :time,
    :track,
    :year,
    :catalog
  ],
  :virtual => {
    :catalog => Catalog.first.id
  }
}

after_post_process_screen(:fatal) {
  album_count = Album.count()
  song_albums = Song.count('album', :distinct => true)
  assert_equal true, (album_count * 0.8) < song_albums
  assert_equal true, song_albums < (album_count * 1.2)
}

after_post_process_screen(:fatal) {
  artist_count = Artist.count()
  song_artists = Song.count('artist', :distinct => true)
  assert_equal true, (artist_count * 0.8) < song_artists
  assert_equal true, song_artists < (artist_count * 1.2)
}

