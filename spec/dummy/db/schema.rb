# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 0) do

# Could not dump table "france_osm_line" because of following StandardError
#   Unknown type 'geometry' for column 'way'

  create_table "france_osm_nodes", :id => false, :force => true do |t|
    t.integer "id",                  :null => false
    t.integer "lat",                 :null => false
    t.integer "lon",                 :null => false
    t.string  "tags", :limit => nil
  end

# Could not dump table "france_osm_point" because of following StandardError
#   Unknown type 'geometry' for column 'way'

# Could not dump table "france_osm_polygon" because of following StandardError
#   Unknown type 'geometry' for column 'way'

  create_table "france_osm_rels", :id => false, :force => true do |t|
    t.integer "id",                     :null => false
    t.integer "way_off", :limit => 2
    t.integer "rel_off", :limit => 2
    t.string  "parts",   :limit => nil
    t.string  "members", :limit => nil
    t.string  "tags",    :limit => nil
    t.boolean "pending",                :null => false
  end

  add_index "france_osm_rels", ["id"], :name => "france_osm_rels_idx"

# Could not dump table "france_osm_roads" because of following StandardError
#   Unknown type 'geometry' for column 'way'

  create_table "france_osm_ways", :id => false, :force => true do |t|
    t.integer "id",                     :null => false
    t.string  "nodes",   :limit => nil, :null => false
    t.string  "tags",    :limit => nil
    t.boolean "pending",                :null => false
  end

  add_index "france_osm_ways", ["id"], :name => "france_osm_ways_idx"

  create_table "geometry_columns", :id => false, :force => true do |t|
    t.string  "f_table_catalog",   :limit => 256, :null => false
    t.string  "f_table_schema",    :limit => 256, :null => false
    t.string  "f_table_name",      :limit => 256, :null => false
    t.string  "f_geometry_column", :limit => 256, :null => false
    t.integer "coord_dimension",                  :null => false
    t.integer "srid",                             :null => false
    t.string  "type",              :limit => 30,  :null => false
  end

  create_table "spatial_ref_sys", :id => false, :force => true do |t|
    t.integer "srid",                      :null => false
    t.string  "auth_name", :limit => 256
    t.integer "auth_srid"
    t.string  "srtext",    :limit => 2048
    t.string  "proj4text", :limit => 2048
  end

end
