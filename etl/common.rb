
# add path to models so we can require them
$:.unshift [File.dirname(__FILE__), '..', 'app', 'models'].join('/')

ActiveRecord::Base.logger = Logger.new(STDOUT)