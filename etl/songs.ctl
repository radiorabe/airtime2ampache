# common boilerplate
$:.unshift File.dirname(__FILE__)
require 'common'

# model for doing foreign key lookups and validation in screens
$:.unshift [File.dirname(__FILE__), '..', 'app', 'models'].join('/')
require 'album'
require 'artist'
require 'song'

pre_process do
  # work around https://github.com/activewarehouse/activewarehouse-etl/issues/32
  ActiveRecord::Base.establish_connection :airtime
end


source :default, {
  :type       => :database,
  :target     => :airtime,
  :query      => 'SELECT track_title, 1 AS catalog, filepath, album_title, artist_name, year, bit_rate, sample_rate, length, track_number FROM cc_files'
}

after_read :print_row

rename :track_title, :title
rename :filepath, :file
rename :album_title, :album
rename :artist_name, :artist
rename :bit_rate, :bitrate
rename :sample_rate, :rate
rename :length, :time
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
transform(:time) {
  # not working as expected :(
  hours, minutes, seconds = :time.split(':').map(&:to_i)
  new((hours * 60 * 60) + (minutes * 60) + seconds)
}

transform :year, :type, :type => :number

before_write :surrogate_key
#before_write :print_row

destination :out, {
  :type     => :database,
  :target   => :ampache,
  :truncate => true,
  :table    => 'song'
},
{
  :order   => [:id, :title, :file, :album, :artist, :bitrate, :rate, :time, :track, :year, :catalog]
}

after_post_process_screen(:fatal) {
  assert_equal Song.count('album', :distinct => true), Album.count()
  assert_equal Song.count('artist', :distinct => true), Artist.count()
}
