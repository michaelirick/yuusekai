class AddWorldIdToUnit < ActiveRecord::Migration[6.1]
  def change
    add_column :units, :world_id, :integer
  end
end