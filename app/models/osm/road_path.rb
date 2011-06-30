class OSM::RoadPath

  attr_accessor :departure, :arrival, :road

  def initialize(attributes = {})
    attributes.each do |k, v|
      send("#{k}=", v)
    end
  end

  def name
    "#{departure.name} -> #{arrival.name} (#{transport_modes.join(',')})"
  end

  delegate :transport_modes, :to => :road

  def endpoints
    [departure, arrival].collect do |endpoint|
      endpoint.location_on_road road
    end.sort
  end

  def locations_on_road
    [departure, arrival].collect do |endpoint|
      endpoint.location_on_road road
    end
  end

  def length
    length_on_road * road.length
  end

  def length_on_road
    begin_on_road, end_on_road = locations_on_road.sort
    end_on_road - begin_on_road
  end

  def self.all(departure, arrivals, road = nil)
    Array(arrivals).collect do |arrival|
      (road ? [road] : departure.common_roads(arrival)).collect do |common_road|
        new :departure => departure, :arrival => arrival, :road => common_road
      end
    end.flatten
  end

  def geometry
    sorted_locations_on_road = locations_on_road.sort
    reverse = (sorted_locations_on_road != locations_on_road)
    geometry = road.line_substring *sorted_locations_on_road
    geometry = geometry.reverse if reverse
    geometry
  end

  def to_s
    name
  end

end
