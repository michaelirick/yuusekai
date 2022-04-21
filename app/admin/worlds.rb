ActiveAdmin.register World do
  menu parent: 'geography', priority: 7, if: proc{true}

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :name
  #
  # or
  #
  # permit_params do
  #   permitted = [:name]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  form do |f|
    f.semantic_errors # shows errors on :base
    f.inputs          # builds an input field for every attribute
    f.actions         # adds the 'Submit' and 'Cancel' buttons
  end

  controller do
    before_action do
      ActiveStorage::Current.host = request.base_url
    end

    def scoped_collection
      end_of_association_chain.where(user_id: current_user.id)
    end

    def map
      world = World.find params[:id]
      mode = params[:mapMode] || 'continents'
      x, y = if params[:center]
        params[:center].try(:split, ',').map &:to_i
      else
        [0 ,0]
      end
      zoom = params[:zoom].to_i + 5
      zoom = 1 if zoom < 1
      puts "zoom: #{zoom}"
      w = 4000 / zoom
      h = 2000 / zoom
      cells = []
      geo_layer_type = mode.singularize.titleize
      box = world.factory.polygon world.factory.linear_ring([
        world.factory.point(x - w / 2, y - h / 2),
        world.factory.point(x - w / 2, y + h / 2),
        world.factory.point(x + w / 2, y + h / 2),
        world.factory.point(x + w / 2, y - h / 2)
                                                            ])
      if mode == 'hexes'
        x, y = GeoLayer.point_to_hex x, y
        if false #zoom < 5
          cells = []
        else
          cells = world.geo_layers.where(type: 'Hex').where(
            "x > ? AND x < ? AND y > ? AND y < ?",
            x - 20, x + 20, y - 20, y + 20
          )
          # cells = world.geo_layers.where(type: geo_layer_type).where("ST_Intersects(ST_geomfromtext('#{box}'), geo_layers.geometry)")
        end
      else
        puts box

        geo_layers = GeoLayer.arel_table
        cells = world.geo_layers.where(type: geo_layer_type).where("ST_Intersects(ST_geomfromtext('#{box}'), geo_layers.geometry)")

        #.where(geo_layers[:geometry].st_contains(box))


      end
      cells = cells.map do |c|
        {
          id: c.id,
          name: c.title,
          points: RGeo::GeoJSON.encode(c.geometry),
          layer: mode,
          type: mode.singularize
        }
      end
      puts cells.count
      # hexes = Hex.all
      # range = 500
      # zoom = params[:zoom].to_i

      # x, y = if params[:center]
      #   params[:center].try(:split, ',').map &:to_i
      # else
      #   [0 ,0]
      # end

      # # TODO: scope to world
      # hexes = Hex.viewable_on_map_at(world, x, y, zoom).map do |h|
      #   Hexes::Index.new(h).to_json
      # end
      hexes = []



      render json: {cells: cells}
    end
  end

  show do |w|
    attributes_table do
      row :name
      row :created_at
    end

    tabs do
      tab 'Continents' do
        table_for GeoLayer.continents_for(w) do
          column :id
          column :title
        end
      end

      tab 'Map' do
        react_component 'Map/index', { world: Worlds::Show.new(w).to_json }
      end
    end
  end

  member_action :select_world, method: :get do
    if resource.user.nil?
      redirect_to resource_path, notice: 'You cannot select this world.'
    else
      u = resource.user
      u.selected_world = resource
      if u.save
        redirect_to resource_path, notice: "You have selected #{resource.name}."
      else
        redirect_to resource_path, notice: "There was an error trying to select that world."
      end
    end
  end

  action_item :select_world, only: [:show] do
    # if current_user.can?(:select_world, character)
      link_to 'Select World', select_world_admin_world_path(world)
    # end
  end

  index do
    selectable_column
    id_column
    column :name

    actions defaults: true do |world|

      link_to 'Select World', select_world_admin_world_path(world), class: 'member_link'
    end
  end

end
