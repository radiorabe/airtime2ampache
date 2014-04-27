# = Class: Catalog
#
class Catalog < ActiveRecord::Base
  establish_connection 'ampache'

  self.table_name = 'catalog'
end
