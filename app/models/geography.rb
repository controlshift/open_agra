class Geography < ActiveRecord::Base
  belongs_to :geographic_collection

  validates :name, presence: true, uniqueness: {scope: :geographic_collection_id}
  validates :shape, presence: true
  validates :geographic_collection, presence: true


  def self.create_with_sql sql
    ActiveRecord::Base.connection.execute(ActiveRecord::Base.send :sanitize_sql_array, sql).first
  end

  def self.from_kml kml, name, collection_id
    create_with_sql ['INSERT INTO geographies (shape, name, geographic_collection_id) VALUES (ST_GeomFromKML(?), ?, ?) RETURNING id', kml, name, collection_id]
  end

  def type
    Geography.where(id: id).select('id, GeometryType(shape) as shape_type').first.shape_type.downcase.to_sym
  end

  def summarize_points max_points = 100
    # TODO: Optimize this
    # Return every nth point where n is n_points / max_points
    # Plus the first and last point (which are the same in a polygon)
    Rails.cache.fetch([self, 'summarize_points']) do
      Geography.where('id = ?', id).
        select('id, (points).geom as shape, (points).path[2] as index, n_points').
        from('(SELECT id, ST_DumpPoints(shape::geometry) as points, ST_NPoints(shape::geometry) as n_points FROM geographies) as _points').
        where('? > n_points OR (points).path[2] % (n_points / ?) = 1 OR (points).path[2] = n_points', max_points, max_points).
        order('index ASC')
    end
  end
end
