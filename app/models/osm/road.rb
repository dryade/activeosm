# CREATE INDEX france_osm_ways_nodes ON france_osm_ways USING gin (nodes);
# insert into spatial_ref_sys VALUES (900913, 'EPSG', 900913, '', '+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs');

class OSM::Road < OSM::Base
  extend ActiveSupport::Memoizable

  set_table_name :france_osm_line
  set_primary_key :osm_id

  has_one :way, :foreign_key => :id, :class_name => "OSM::Way"

  acts_as_geom :way => :line_string

  def self.instance_method_already_implemented?(method_name)
    return true if method_name == 'boundary'
    super
  end

  # Ignore : service pedestrian
  @@supported_highway_tag_values = %w{motorway trunk primary secondary tertiary motorway_link primary_link unclassified road residential track}
  cattr_reader :supported_highway_tag_values

  @@supported_railway_tag_values = %w{rail tram}
  cattr_reader :supported_railway_tag_values

  def self.highway_conditions
    quote_marks = %w{?} * supported_highway_tag_values.size
    ["highway in (#{quote_marks.join(',')})", supported_highway_tag_values].flatten
  end

  if respond_to?(:scope)
    scope :highway, where(*highway_conditions)
  else
    named_scope :highway, :conditions => highway_conditions
  end

  def self.railway_conditions
    quote_marks = %w{?} * supported_railway_tag_values.size
    ["railway in (#{quote_marks.join(',')})", supported_railway_tag_values].flatten
  end

  if respond_to?(:scope)
    scope :railway, where(*railway_conditions)
  else
    named_scope :railway, :conditions => railway_conditions
  end

  def self.default_conditions
    [ "#{highway_conditions.first} or #{railway_conditions.first}", highway_conditions.from(1), railway_conditions.from(1) ].flatten
  end

  default_scope :conditions => default_conditions

  def transport_modes
    [].tap do |modes|
      modes << :highway if highway?
      modes << :railway if railway?
    end
  end

  def highway?
    supported_highway_tag_values.include?(highway)
  end

  def railway?
    supported_railway_tag_values.include?(railway)
  end

  def to_s
    name or "#{osm_id}:#{transport_modes.join(':')}"
  end

  def neighbors
    self.class.find_by_osm_id way.neighbors
  end

  def self.find_all_by_nodes(nodes)
    find_all_by_osm_id(OSM::Way.find_all_by_nodes(nodes)).compact
    # cache.find_all_by_nodes(nodes)
  end

  class Cache

    def find_all_by_nodes(nodes)
      node_ids = Array(nodes).collect do |node|
        Integer === node ? node : node.id 
      end

      [].tap do |roads|
        missed_nodes = []

        node_ids.each do |node_id|
          cached_roads = Rails.cache.read("OSM::Road::by_node::#{node_id}")
          if cached_roads.present?
            Rails.logger.debug "Find #{cached_roads.join(',')} associated to #{node_id}"
            roads.concat cached_roads
          else
            missed_nodes << node_id
          end
        end

        if missed_nodes.present?
          missed_nodes.each do |node_id|
            read_roads = OSM::Road.find_all_by_osm_id(OSM::Way.find_all_by_nodes(node_id)).compact
            Rails.logger.debug "Associate OSM::Node##{node_id} with #{read_roads.join(',')}"
            Rails.cache.write("OSM::Road::by_node::#{node_id}", read_roads)

            roads.concat read_roads
          end
        end
      end.uniq
    end

  end

  @@cache = OSM::Road::Cache.new
  cattr_reader :cache

  def junctions
    way.node_ids.collect do |node|
      OSM::Junction.find_by_node node
    end.compact
  end

  def self.find_by_position(position)
    Finder.new(position).road
  end

  def self.find_all_by_bounds(bounds)
    ne_corner, sw_corner = bounds.upper_corner, bounds.lower_corner
    sql_box = "SetSRID('BOX3D(#{ne_corner.lng} #{ne_corner.lat}, #{sw_corner.lng} #{sw_corner.lat})'::box3d, 900913)"
    find :all, :conditions => "way && #{sql_box}"
  end

  def geometry
    read_attribute :way
  end

  def length
    @length ||= geometry.euclidian_distance
  end
  # memoize :length

  # memoize :locate_point

  class Finder
    extend ActiveSupport::Memoizable

    attr_reader :position

    def initialize(position)
      @position = position
    end

    def wgs84_position
      position.google_to_wgs84
    end
    memoize :wgs84_position

    def box_size
      0.5
    end

    def endpoint(heading)
      wgs84_position.endpoint(heading, box_size, :units => :kms).wgs84_to_google
    end

    def sw_corner
      endpoint(180 + 45)
    end
    memoize :sw_corner

    def ne_corner
      endpoint(45)
    end
    memoize :ne_corner

    def sql_box
      "SetSRID('BOX3D(#{ne_corner.lng} #{ne_corner.lat}, #{sw_corner.lng} #{sw_corner.lat})'::box3d, 900913)"
    end

    def sql_point
      "SetSRID(PointFromText('POINT(#{position.lng} #{position.lat})'), 900913)"
    end
      
    def road
      OSM::Road.find :first, :conditions => "way && #{sql_box}", :order => "Distance(way, #{sql_point})"
    end

  end

end
