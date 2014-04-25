# common boilerplate
$:.unshift File.dirname(__FILE__)
require 'common'

pre_process do
  # work around https://github.com/activewarehouse/activewarehouse-etl/issues/32
  ActiveRecord::Base.establish_connection :airtime
end


source :default, {
  :type       => :database,
  :target     => :airtime,
  :query      => 'SELECT DISTINCT album_title, year, disc_number FROM cc_files'
}

#after_read :print_row

rename :album_title, :name
rename :disc_number, :disk
transform :year, :type, :type => :number

before_write :surrogate_key
#before_write :print_row

destination :out, {
  :type     => :database,
  :target   => :ampache,
  :truncate => true,
  :table    => 'album'
},
{
  :order   => [:id, :name, :year, :disk]
}
