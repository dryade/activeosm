# Quick howto
# 
# Download the osm file:
# wget http://download.geofabrik.de/osm/europe/france/nord-pas-de-calais.osm.bz2
#
# Create an empty postgis database:
# createdb --template=template_postgis osm
#
# Add EPSG 900913:
# insert into spatial_ref_sys VALUES (900913, 'EPSG', 900913, '', '+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs');
#
# Import osm file:
# osm2pgsql --slim --create --database osm --prefix france_osm nord-pas-de-calais.osm.bz2
#
# Create an index for nodes:
# CREATE INDEX france_osm_ways_nodes ON france_osm_ways USING gin (nodes);
#
# Modify osm: configuration in config/database,yml if needed

require 'shortest_path'

class OSM::ShortestPath < ShortestPath
  extend ActiveSupport::Memoizable

  attr_reader :transport_mode

  def initialize(source, destination, transport_mode = :highway)
    @transport_mode = transport_mode.to_sym
    super to_road_access(source), to_road_access(destination)
  end

  def to_road_access(location)
    Geokit::LatLng === location ? OSM::RoadAccess.new(location, transport_mode) : location
  end

  def distance_heuristic(node)
    node.to_lat_lng.google_to_wgs84.distance_to(destination.to_lat_lng.google_to_wgs84, :units => :kms) * 1000
  end
  memoize :distance_heuristic

  def search_heuristic(node)
    shortest_distances[node] + distance_heuristic(node)
  end

  def follow_way?(node, destination, weight)
    search_heuristic(node) + weight < distance_heuristic(source) * 10
  end

  def ways(node)
    Rails.logger.debug { "Looking for ways for #{node} (#{distance_heuristic(node)}/#{search_heuristic(node)})" }

    paths = node.paths

    if node.on_road? destination.road
      paths << OSM::RoadPath.new(:departure => node, :arrival => destination, :road => destination.road)
    end

    paths = paths.select do |path|
      if path.transport_modes.include?(transport_mode)
        true
      else
        Rails.logger.debug { "Ignore #{path.name}/#{path.transport_modes.inspect}, wrong transport mode (#{transport_mode.inspect})" }
        false
      end
    end

    paths.inject({}) do |ways, path|
      if path.length > 0
        # If the same arrival is accessible via two paths .. only keep the smallest
        unless ways[path.arrival] and ways[path.arrival] <= path.length
          Rails.logger.debug { "Possible way #{path.arrival} at #{path.length}" }
          ways.merge path.arrival => path.length 
        else
          ways
        end
      else
        Rails.logger.warn { "Ignore way #{path.arrival} at #{path.length}" }
        ways
      end
    end
  end

  def path
    nodes = super

    previous = nodes.shift
    nodes.collect do |node|
      # FIXME the select road isn't the shortert way
      road = (previous.roads & node.roads).first

      OSM::RoadPath.new(:departure => previous, :arrival => node, :road => road).tap do 
        previous = node
      end
    end
  end

  def self.preload_osm_classes
    [OSM::RoadPath, OSM::Junction, OSM::Road, OSM::Way, OSM::Node]
  end

  def to_cache
    self.class.preload_osm_classes # required to unmarshall cached results
    Cache.new(self, source.origin, destination.origin, transport_mode)
  end

end
