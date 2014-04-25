
# common boilerplate
$:.unshift File.dirname(__FILE__)
require 'common'

pre_process do
  # work around https://github.com/activewarehouse/activewarehouse-etl/issues/32
  ActiveRecord::Base.establish_connection :airtime
end

source :default, {
  :type       => :enumerable,
  :enumerable => [
    :id           => 1,
    :name         => 'airtime',
    :path         => '/var/nfs/airtime',
    :catalog_type => 'remote',
    :enabled      => true
  ]
}

destination :out, {
  :type     => :database,
  :target   => :ampache,
  :truncate => true,
  :table    => 'catalog'
},
{
  :order => [:id, :name, :path, :catalog_type, :enabled]
}
