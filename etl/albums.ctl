# common boilerplate
$LOAD_PATH.unshift File.dirname(__FILE__)
require 'common'

pre_process do
  # workaround https://github.com/activewarehouse/activewarehouse-etl/issues/32
  ActiveRecord::Base.establish_connection :airtime
end

source :default,
       type:   :database,
       target: :airtime,
       query:  'SELECT DISTINCT album_title, year, disc_number FROM cc_files'

rename :album_title, :name
rename :disc_number, :disk

transform :year, :type, type: :number

transform :name,   :default, default_value: ''
transform :disk,   :default, default_value: 0
transform :prefix, :default, default_value: ''

before_write :surrogate_key

destination :out,
            {
              type:     :database,
              target:   :ampache,
              truncate: true,
              table:    'album'
            },
            order: [:id, :name, :year, :disk, :prefix]
