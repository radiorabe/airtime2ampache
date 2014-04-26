
# common boilerplate
$LOAD_PATH.unshift File.dirname(__FILE__)
require 'common'

source :default,
       type:   :database,
       target: :airtime,
       query:  'SELECT DISTINCT artist_name FROM cc_files'

rename :artist_name, :name

before_write :surrogate_key

destination :out,
            {
              type:     :database,
              target:   :ampache,
              truncate: true,
              table:    'artist'
            },
            order: [:id, :name]
