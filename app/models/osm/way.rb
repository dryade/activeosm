class OSM::Way < OSM::Base
  set_table_name :france_osm_ways

  def node_ids
    read_attribute(:nodes).tr("{}","").split(",").map(&:to_i)
  end

  # def nodes
  #   OSM::Node.find node_ids
  # end

  def neighbors
    self.class.find_all_by_nodes node_ids
  end

  def self.find_all_by_nodes(nodes)
    # nodes = Array(nodes).map { |node| Integer === node ? node : node.id  }
    # find_by_sql "select * from france_osm_ways where nodes && array[#{nodes.join(',')}]";
    Array(nodes).collect do |node|
      find_all_by_node(node)
    end.flatten
  end

  def self.find_all_by_node(node)
    query=<<EOF
    select france_osm_ways.id from france_osm_ways 
      INNER JOIN france_osm_line ON (france_osm_ways.id = france_osm_line.osm_id)
      where ST_DWithin(ST_GeomFromText('POINT(#{node.lon / 100.0} #{node.lat / 100.0})', 900913), france_osm_line.way, 10) and france_osm_ways.nodes && array[#{node.id}];
EOF
    find_by_sql query
  end
end
