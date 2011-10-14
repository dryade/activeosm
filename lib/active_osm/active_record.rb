require 'postgis_adapter'

class OSM::ActiveRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.database_configuration_provider
    defined?(Rails) ? Rails.configuration : ActiveOSM
  end

  # establish_connection :osm doesn't work :(
  establish_connection database_configuration_provider.database_configuration["osm"]

end
