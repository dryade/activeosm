
module ActiveOSM

  def self.database_configuration
    YAML::load(ERB.new(IO.read('config/database.yml')).result)
  end

end

module OSM

end

require 'active_osm/version'

require 'active_record'
require 'erb'

require 'active_osm/active_record'

require 'active_osm/node'
require 'active_osm/way'

require 'active_osm/road'
require 'active_osm/junction'

require 'active_osm/road_access'
require 'active_osm/road_path'

require 'active_osm/shortest_path'


