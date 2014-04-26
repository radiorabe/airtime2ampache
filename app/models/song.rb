# = Class: Song
#
class Song < ActiveRecord::Base
  establish_connection 'ampache'

  self.table_name = 'song'
end
