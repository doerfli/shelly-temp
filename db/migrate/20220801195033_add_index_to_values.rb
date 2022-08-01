class AddIndexToValues < ActiveRecord::Migration[7.0]
  def change
    add_index :values, :created_at
  end
end
