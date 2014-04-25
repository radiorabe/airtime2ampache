
class Album < ActiveRecord::Base
  establish_connection "ampache"

  self.table_name = "album"

  def self.find_id_by_name(name)
    self.where(name: name).first
  end
end
