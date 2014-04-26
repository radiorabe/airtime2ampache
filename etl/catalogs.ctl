
# common boilerplate
$LOAD_PATH.unshift File.dirname(__FILE__)
require 'common'

# models vor validation
require 'catalog'

pre_process do
  # workaround https://github.com/activewarehouse/activewarehouse-etl/issues/32
  ActiveRecord::Base.establish_connection :airtime
end

source :default,
       type:       :enumerable,
       enumerable: [
         id:           1,
         name:         'airtime',
         path:         '/var/nfs/airtime',
         catalog_type: 'remote',
         enabled:      true
       ]

destination :out,
            {
              type:     :database,
              target:   :ampache,
              truncate: true,
              table:    'catalog'
            },
            order:      [:id, :name, :path, :catalog_type, :enabled]

after_post_process_screen(:fatal) do
  assert_equal 1, Catalog.count
end
