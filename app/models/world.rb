class World < ApplicationRecord
  include GeoLayerable
  resourcify
  has_many :states
  # has_many :contine/nts
  has_many :map_layers
  has_many :geo_layers
  # has_many :hegxes
  belongs_to :user
  has_many :settlements
  has_many :cultures
  has_many :biomes
  # add_geo_layer(
  #   name: 'World',
  #   subordinates: :continents
  # )

  HEX_RADIUS = 6.0469 # miles

  scope :for_user, -> (user) { where(user: user) }

  def factory
    @factory ||= RGeo::Cartesian.factory
    @factory
  end

  def reset_geometry!

  end

  def pixel_length
    (circumference || 1.0) / (resolution_x || 1.0)
  end

  def hex_radius
    HEX_RADIUS / pixel_length
  end

  # odd-q hexes
  def point_to_hex(x, y)
    q = ((2.0/3 * x) / hex_radius).round
    r = ((-1.0/3 * x + Math.sqrt(3)/3 * y) / hex_radius).round
    ny = r + (q - (q & 1))/2
    [q, ny]
  end

  def range_to_hex(x, y)
    ax, ay = point_to_hex(x.first, y.first)
    bx, by = point_to_hex(x.last, x.last)

    [ax..bx, ay..by]
  end

  def range_to_point(x, y)
    ax, ay = hex_to_point(x.first, y.first)
    bx, by = hex_to_point(x.last, x.last)

    [ax..bx, ay..by]
  end

  # odd-q hexes
  def hex_to_point(x, y)
  radius = hex_radius
  nx = radius * x * 3.0/2
  ny = radius * Math.sqrt(3) * (y + 0.5 * (x & 1))
  [nx, ny]
  end

  def draw_hex(center)
    radius = hex_radius
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

  def hex_geometry(points)
    points = points.map do |p|
      px, py = p
      factory.point(px, py)
    end

    geometry_from_points points
  end

  def geometry_from_points(points)
    ring = factory.linear_ring points
    polygon = factory.polygon(ring)
    factory.collection([polygon])
  end

  def quick_hex_string(points)
    "GEOMETRY_COLLECTION (POLYGON ((#{points.map {|point| "#{point.join(' ')}"}.join(', ')})))"
  end


  def quick_hex(x, y)
    hex_geometry(draw_hex(hex_to_point(x, y)))
  end

  def all_hex_coordinates(x_range: nil, y_range: nil)
    x_range ||= 0..resolution_x
    y_range ||= 0..resolution_y
    new_hexes = []
    # last_percent = 0
    x_range.step(hex_radius) do |x|
      y_range.step(hex_radius) do |y|
        new_hexes << point_to_hex(x, y)
      end

      # percent = (x / resolution_x.to_f * 100).round
      # puts "#{percent}%" if percent % 5 == 0 && percent != last_percent
      # last_percent = percent
    end

    # puts "removing duplicates"
    new_hexes = new_hexes.uniq

    new_hexes
  end

  def regenerate_hexes!(x_range: nil, y_range: nil)
    x_range ||= 0..resolution_x
    y_range ||= 0..resolution_y
    hex_range_x, hex_range_y = range_to_hex(x_range, y_range)
    GeoLayer.transaction do
      puts "Deleting..."
      geo_layers.where(type: 'Hex', x: hex_range_x, y: hex_range_y).delete_all

      puts "Generating #{x_range.count * y_range.count} new coords..."
      new_hexes = []
      last_percent = 0
      x_range.step(hex_radius) do |x|
        y_range.step(hex_radius) do |y|
          new_hexes << point_to_hex(x, y)
        end

        percent = (x / x_range.count.to_f * 100).round
        puts "#{percent}%" if percent % 5 == 0 && percent != last_percent
        last_percent = percent
      end

      puts "removing duplicates"
      new_hexes = new_hexes.uniq

      puts "#{new_hexes.count} hexes to create"

      puts "allocating colors..."
      new_colors = UniqueColor.allocate_color(self, 'geo_layers', 'color', new_hexes.count)

      puts "creating hex data..."
      last_percent = 0
      new_hex = {
        parent_id: id,
        world_id: id,
        type: 'Hex',
        parent_type: 'World',
        created_at: Time.now,
        updated_at: Time.now
      }
      new_hexes = new_hexes.map.with_index do |coords, i|
        percent = (i / new_hexes.count.to_f * 100).round
        puts "#{percent}%" if percent % 5 == 0 && percent != last_percent
        last_percent = percent
        x, y = coords
        new_hex.merge({
          title: "#{x}, #{y}",
          color: new_colors[i],
          x: x,
          y: y,
          geometry: quick_hex(x, y)
        })
      end

      puts "inserting in slices of 1000..."
      last_percent = 0
      new_hexes.each_slice(10000).with_index do |slice, i|
        percent = (i / (new_hexes.count / 10000).to_f * 100).round
        puts "#{percent}%" #if percent % 5 == 0 && percent != last_percent
        last_percent = percent
        Hex.insert_all slice
      end

      puts "done"
    end
  end
  # GEO_LAYER_TYPES = %i[
  #   continent
  #   subcontinent
  #   region
  #   area
  #   province
  # ].freeze

  # # inverse mapping to the relation needed to group
  # %i[
  #   subcontinents
  #   regions
  #   areas
  #   provinces
  # ].each do |sub|
  #   define_method sub do
  #     geo_subordinates.map(&sub).flatten
  #   end
  # end

  # # def subcontinents
  # #   continents.map(&:subcontinents)
  # # end

  # def geo_layers
  #   GEO_LAYER_TYPES.map do |glt|
  #     {
  #       name: glt,
  #       points: send(glt.to_s.pluralize).map do |sub|
  #         {name: sub.name, points: sub.to_geojson}
  #       end
  #     }
  #   end
  # end

  # def geo_factory
  #   RGeo::Cartesian.preferred_factory()
  # end
end
