# = Class: Artist
#
class Artist < ActiveRecord::Base
  establish_connection 'ampache'

  self.table_name = 'artist'

  def self.find_id_by_name(name)
    where(name: name).first
  end
end
