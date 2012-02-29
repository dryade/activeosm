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
    nodes = Array(nodes).map { |node| Integer === node ? node : node.id  }
    find_by_sql "select * from france_osm_ways where nodes && array[#{nodes.join(',')}]";
  end
end
