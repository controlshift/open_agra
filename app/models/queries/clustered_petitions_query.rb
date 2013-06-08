module Queries
  class ClusteredPetitionsQuery < Queries::Query
    attr_accessor :country, :category, :organisation, :k
    validates :organisation, presence: true
    validates :k, presence: true, numericality: true

    def initialize(attrs = {})
      self.k = 10
      super(attrs)
    end

    def clustered_locations_as_json
      sql = <<-SQL
      SELECT array_to_json(array_agg(latlons)) FROM ( -- Render as JSON
        SELECT ST_X(centroid) as longitude, ST_Y(centroid) as latitude, cluster, country, locations from ( -- Convert points back into latlons
          SELECT kmeans as cluster, ST_Centroid(ST_Collect(point)) as centroid, array_to_json(array_agg(petition_latlons)) as locations, country
FROM ( -- Collect centers of kmeans groupings
          SELECT kmeans(ARRAY[ST_X(point), ST_Y(point)], ?) OVER (PARTITION BY locations.country),
            (SELECT row_to_json(locs) FROM (VALUES (ST_X(point), ST_Y(point), query)) locs(longitude, latitude, query) ) as petition_latlons,
            point, country
          FROM (
              #{ points_sql_fragment }
            ) as locations
          ) AS ksub
          GROUP BY kmeans, country
          ORDER BY kmeans
        ) as centroids
      ) as latlons;
      SQL
      query = ActiveRecord::Base.send(:sanitize_sql_array, [sql, k])
      result = ActiveRecord::Base.connection.execute query
      result.first['array_to_json']
    end

    def locations_as_json
       query = petitions_filter.select("array_to_json(array_agg(locations.*))").to_sql
       result = ActiveRecord::Base.connection.execute query
       result.first['array_to_json']
    end


    def points_sql_fragment
      points = petitions_filter.select("locations.point as point, locations.country as country, locations.query as query")
      points.to_sql
    end

    def petitions_filter
      petitions = organisation.petitions.appropriate_unordered.joins(:location)
      petitions = petitions.where("locations.country = ?", country) if country.present?
      if category.present?
        petitions = petitions.where("categorized_petitions.category_id = ?", category.id)
          .joins(:categorized_petitions)
      end

      petitions
    end

  end
end