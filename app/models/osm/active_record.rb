require 'postgis_adapter'

class OSM::ActiveRecord < ActiveRecord::Base
  self.abstract_class = true
  establish_connection({
    :adapter => "postgresql",
    :database => "osm",
    :username => "osm",
    :password => "osm",
    :host => "osm.dryade.priv"
  })
end
