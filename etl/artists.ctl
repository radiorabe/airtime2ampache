
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
       query:  'SELECT DISTINCT artist_name FROM cc_files'

rename :artist_name, :name

transform :prefix, :default, default_value: ''

before_write :surrogate_key

destination :out,
            {
              type:     :database,
              target:   :ampache,
              truncate: true,
              table:    'artist'
            },
            order: [:id, :name, :prefix]
