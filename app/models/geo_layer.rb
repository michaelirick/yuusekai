class GeoLayer < ApplicationRecord
  belongs_to :world
  belongs_to :parent, polymorphic: true
  belongs_to :owner, polymorphic: true, optional: true
  has_many :children, class_name: 'GeoLayer', as: :parent
  has_one :de_jure, class_name: 'State'

  HEX_RADIUS = 6.0469
  BIOME_TYPES = %w[
    polar_desert
    ice
    subpolar_dry_tundra
    subpolar_moist_tundra
    subpolar_wet_tundra
    subpolar_rain_tundra
    boreal_dry_scrub
    boreal_moist_forest
    boreal_wet_forest
    boreal_rain_forest
    cool_temperate_desert
    cool_temperate_desert_scrub
    cool_temperate_steppe
    cool_temperate_moist_forest
    cool_temperate_wet_forest
    cool_temperate_rain_forest
    warm_temperate_desert
    warm_temperate_desert_scrub
    warm_temperate_thorn_scrub
    warm_temperate_dry_forest
    warm_temperate_moist_forest
    warm_temperate_wet_forest
    warm_temperate_rain_forest
    subtropical_desert
    subtropical_desert_scrub
    subtropical_thorn_woodland
    subtropical_dry_forest
    subtropical_moist_forest
    subtropical_wet_forest
    subtropical_rain_forest
    tropical_desert
    tropical_desert_scrub
    tropical_thorn_woodland
    tropical_very_dry_forest
    tropical_dry_forest
    tropical_moist_forest
    tropical_wet_forest
    tropical_rain_forest
  ]

  TERRAIN_TYPES = %w[
    deep_ocean
    shallow_sea
    river
    lake
    plains
    hills
    mountains
    impassible_mountains
  ]

  after_commit :update_parent_geometry
  after_commit :update_owner_geometry
  after_commit :ensure_color_generated

  def ensure_color_generated
    if color.nil? || !has_unique_color?
      generate_color!
    end
  end

  def generate_color!
    range = %w[0 1 2 3 4 5 6 7 8 9 a b c d e f]
    self.color = '#' + 6.times.map { |i| range.sample }.join
    save!
  end

  def has_unique_color?
    world.geo_layers.where.not(id: id).where(color: color).count == 0
  end

  def change_geometry_for_parent?
    previous_changes[:geometry] || previous_changes[:parent_id] || previous_changes[:parent_type] || destroyed? || previously_new_record? || type == 'Hex'
  end

  def all_hexes
    geo_layer = GeoLayer.arel_table
    Hex.where(world: world).where(geo_layer[:geometry].st_intersects(geometry))
  end

  def update_parent_geometry
    puts 'update_parent_geometry'
    unless parent
      puts "no parent"
      return
    end
    if parent_type == 'World'
      puts 'parent is World'
    end

    if change_geometry_for_parent?
      puts 'parent changed'
      parent.reset_geometry!
    end
    puts "changes:"
    # puts self.methods.sort
  end

  def change_geometry_for_owner?
    previous_changes[:geometry] || previous_changes[:owner_type] || previous_changes[:owner_id] || destroyed? || previously_new_record? || type == 'Hex'
  end
  def update_owner_geometry
    puts 'update_owner_geometry'
    unless owner
      puts "no owner"
      return
    end
    if owner_type == 'World'
      puts 'owner is World'
    end

    if change_geometry_for_owner?
      puts 'owner changed'
      owner.reset_geometry!
    end
    puts "changes:"
    # puts self.methods.sort
  end

  def self.add_geo_layer_level(layer)
    @geo_layer_levels = [] unless @geo_layer_levels
    @geo_layer_levels << layer
    scope :"#{layer.to_s.pluralize}_for", -> (world) { where(type: layer.to_s.classify, world: world) }
  end

  def self.geo_layer_levels
    @geo_layer_levels
  end

  def self.for(world)
    @geo_layer_levels.map do |layer|
      { layer.to_s.pluralize.to_sym => send(:"#{layer.to_s.pluralize}_for", world) }
    end.reduce :merge
  end

  def factory
    world.factory
  end

  def all_children_ids
    (children.map(&:id) + children.map(&:all_children_ids)).flatten.uniq
  end

  def self.reset_geometry_for!(world, options={})
    classes = [Hex, Province, Area, Region, Subcontinent, Continent]
    classes -= options[:except] || []
    classes.each do |c|
      puts "Resetting #{c}..." if ENV['DEBUG'] == '1'
      c.where(world: world).each &:reset_geometry!
    end
  end

  # odd-q hexes
  def self.point_to_hex(x, y)
    q = ((2.0/3 * x) / HEX_RADIUS).round
    r = ((-1.0/3 * x + Math.sqrt(3)/3 * y) / HEX_RADIUS).round
    ny = r + (q - (q & 1))/2
    [q, ny]
  end

  # odd-q hexes
  def self.hex_to_point(x, y)
    radius = HEX_RADIUS
    nx = radius * x * 3.0/2
    ny = radius * Math.sqrt(3) * (y + 0.5 * (x & 1))
    [nx, ny]
  end

  def self.draw_hex(center)
    radius = HEX_RADIUS
    x, y = center
    sides = 6
    grade = 2 * Math::PI / sides
    sides.times.map do |i|
      [
        (Math.cos(grade * i) * radius) + x,
        (Math.sin(grade * i) * radius) + y
      ]
    end
  end

  def self.hex_geometry(points, factory)
    points = points.map do |p|
      px, py = p
      factory.point(px, py)
    end

    ring = factory.linear_ring points
    polygon = factory.polygon(ring)
    factory.collection([polygon])
  end

  def reset_hex!
    self.geometry = GeoLayer.hex_geometry GeoLayer.draw_hex(GeoLayer.hex_to_point(x, y)), factory
    save!
  end

  def reset_geometry!
    if type == 'Hex'
      reset_hex!
      return
    end
    new_geometry = GeoLayer.connection.execute(%(
      SELECT st_asgeojson(st_union(a.new_geometry)) AS new_geometry
from
      (SELECT st_asgeojson(st_union(geometry)) AS new_geometry
      FROM geo_layers
      WHERE parent_id=#{id} AND parent_type='GeoLayer') a
                                               )).map(&:to_h).first['new_geometry']
#     new_geometry = GeoLayer.connection.execute(%(
#       SELECT st_asgeojson(st_union(st_snaptogrid(geometry, 0.0001))) AS new_geometry
#       FROM geo_layers
#       WHERE parent_id=#{id} AND parent_type='GeoLayer'
#                                                )).map(&:to_h).first['new_geometry']

    polygons = children.pluck(:geometry).compact.map(&:to_a).flatten

    new_geometry = RGeo::GeoJSON.decode new_geometry
    self.geometry = factory.collection [new_geometry].compact
    self.save!
  rescue => e
    puts "#{type} #{id} #{title} failed to reset geometry:"
    puts e.full_message
  end

  def update_geometry!(points)
    puts "points: #{points.inspect}"
    points = points.map do |x, y|
      factory.point(x, y)
    end

    self.geometry = factory.collection [factory.polygon(factory.linear_ring(points))]
    save!
  end

  scope :for_world, ->(w) { where world: w }

  add_geo_layer_level :continent
  add_geo_layer_level :subcontinent
  add_geo_layer_level :region
  add_geo_layer_level :area
  add_geo_layer_level :province
  # Hex is too much
  # add_geo_layer_level :hex
end
