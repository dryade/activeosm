class ShortestPath

  attr_reader :source, :destination

  def initialize(source, destination)
    @source, @destination = source, destination
  end

  # Should return a map with accessible nodes and associated weight
  # Example : { :a => 2, :b => 3 }
  attr_accessor :ways_finder

  def ways(node)
    ways_finder.call node
  end

  def shortest_distances
    @shortest_distances ||= {}
  end

  def previous
    @previous ||= {}
  end

  def search_heuristic(node)
    shortest_distances[node]
  end

  def follow_way?(node, destination, weight)
    true
  end

  attr_accessor :timeout
  attr_reader :begin_at, :end_at
  
  def timeout?
    timeout and (duration > timeout)
  end

  def duration
    return nil unless begin_at
    (end_at or Time.now) - begin_at
  end

  class TimeoutError < StandardError
  end

  def path
    @begin_at = Time.now
    
    visited = {}
    pq = PQueue.new(proc {|x,y| search_heuristic(x) < search_heuristic(y)})

    pq.push(source)
    visited[source] = true
    shortest_distances[source] = 0

    not_found = (source != destination)

    while pq.size != 0 && not_found
      raise TimeoutError if timeout?

      v = pq.pop
      not_found = (v != destination)
      visited[v] = true

      weights = ways(v)
      if weights
        weights.keys.each do |w|
          if !visited[w] and
              weights[w] and
              ( shortest_distances[w].nil? || shortest_distances[w] > shortest_distances[v] + weights[w]) and 
              follow_way?(v, w, weights[w])
            shortest_distances[w] = shortest_distances[v] + weights[w]
            previous[w] = v
            pq.push(w)
          end
        end
      end
    end

    @end_at = Time.now
    not_found ? [] : sorted_array
  end

  def sorted_array
    [].tap do |sorted_array|
      previous_id = destination
      previous.size.times do |t|
        sorted_array.unshift(previous_id)
        break if previous_id == source
        previous_id = previous[ previous_id]
        raise "Unknown #{previous_id}" unless previous_id
      end
    end
    
  rescue => e
    return []
  end

  def to_cache
    Cache.new(self, source, destination)
  end

  class Cache

    attr_reader :implementation_class

    def initialize(implementation, *arguments)
      if implementation === Class
        @implementation_class = implementation
      else
        @implementation_class = implementation.class
        @implementation = implementation
      end

      @arguments = arguments
    end

    def implementation
      @implementation ||= implementation_class.new *arguments
    end

    def cache_key
      ([implementation_class] + @arguments).join(':')
    end

    def cached_path
      Rails.cache.read cache_key
    end

    def cached_path=(path)
      Rails.cache.write cache_key, path
    end

    def path
      self.cached_path ||= implementation.path
    end

  end

end
