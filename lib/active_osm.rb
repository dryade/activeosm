module ActiveOSM
  class Engine < Rails::Engine
    initializer "initialize connection to OSM" do
      config.after_initialize do
        # establish_connection :osm (here or into OSM::ActiveRecord) doesn't work with 3.0.7
        OSM::ActiveRecord.establish_connection Rails.configuration.database_configuration["osm"]
      end
    end
  end
end
