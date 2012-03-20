class OSM::Junction
  extend ActiveSupport::Memoizable

  attr_accessor :node_id, :roads

  def self.find_by_node(node)
    if Integer === node
      node = OSM::Node.find(node)
    end
    connected_roads = OSM::Road.find_all_by_nodes(node)
    unless connected_roads.size < 2
      OSM::Junction.new :node => node, :roads => connected_roads
    end
  end

  def initialize(attributes = {})
    attributes.each do |k, v|
      send("#{k}=", v)
    end
  end

  def node
    @node ||= OSM::Node.find(node_id)
  end

  def node=(node)
    if Integer === node
      self.node_id = node
    else
      @node = node
    end
  end

  def neighbors
    roads.collect(&:junctions).flatten.uniq - [self]
  end

  def eql?(other)
    other.respond_to?(:node) and node == other.node
  end
  alias_method :==, :eql?
  alias_method :equal?, :eql?

  def hash
    node.hash
  end

  delegate :to_lat_lng, :to => :node

  def on_road?(road)
    self.roads.include? road
  end

  def common_roads(junction)
    junction and roads & junction.roads
  end

  def location_on_road(road)
    road.locate_point self
  end
  memoize :location_on_road

  def paths
    OSM::RoadPath.all self, self.neighbors
  end

  def name
    roads.collect { |r| r.to_s }.join(" - ")
  end

  def to_s
    "#{name} (#{node.id}@#{to_lat_lng})"
  end

end
