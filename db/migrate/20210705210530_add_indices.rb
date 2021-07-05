class AddIndices < ActiveRecord::Migration[6.1]
  def change
    add_index :devices, :ident
    add_index :devices, :name
    add_index :types, :name
  end
end
