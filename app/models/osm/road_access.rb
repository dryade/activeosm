class OSM::RoadAccess
  extend ActiveSupport::Memoizable

  attr_accessor :origin, :scope

  def initialize(origin, scope = nil)
    @origin, @scope = origin, scope
  end

  def road
    (scope ? OSM::Road.send(scope) : OSM::Road).find_by_position origin
  end
  memoize :road

  def roads
    [road]
  end

  def on_road?(road)
    self.road == road
  end

  def location_on_road(road = nil)
    (road or self.road).locate_point self
  end

  def paths
    OSM::RoadPath.all self, road.junctions, road
  end

  delegate :to_lat_lng, :to => :origin

  def name
    "Access on #{road}"
  end

  def to_s
    name
  end

end
