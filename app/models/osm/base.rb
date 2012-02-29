class OSM::Base < ActiveRecord::Base
  self.abstract_class = true

  establish_connection :osm
end
