class OSM::Node < OSM::ActiveRecord
  set_table_name :france_osm_nodes
  set_primary_key :id

  def to_lat_lng
    Geokit::LatLng.new lat / 100, lon / 100
  end

  def to_s
    "OSM::Node##{id}"
  end

end
