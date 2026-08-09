class AddLookupIndexToValues < ActiveRecord::Migration[8.1]
  def change
    add_index :values, [:device_id, :type_id, :created_at]
  end
end
