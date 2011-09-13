require 'postgis_adapter'

class OSM::ActiveRecord < ActiveRecord::Base
  self.abstract_class = true

  # establish_connection :osm doesn't work :(
  establish_connection Rails.configuration.database_configuration["osm"]

end
