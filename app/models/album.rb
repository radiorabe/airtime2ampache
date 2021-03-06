# = Class: Album
#
class Album < ActiveRecord::Base
  establish_connection 'ampache'

  self.table_name = 'album'

  def self.find_id_by_name(name)
    where(name: name).first
  end
end
