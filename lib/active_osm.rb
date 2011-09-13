module ActiveOSM
  class Engine < Rails::Engine
    initializer "initialize connection to OSM" do
      config.after_initialize do
        
      end
    end
  end
end
