class OSM::Node < OSM::Base
  set_table_name :france_osm_nodes

  def to_lat_lng
    @lat_lng ||= Geokit::LatLng.new lat / 100, lon / 100
  end

  def geometry
    @geometry ||= GeoRuby::SimpleFeatures::Point.from_lat_lng self, 900913
  end

  def to_s
    "OSM::Node##{id}"
  end

end
