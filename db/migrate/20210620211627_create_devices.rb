class CreateDevices < ActiveRecord::Migration[6.1]
  def change
    create_table :devices do |t|
      t.string :ident
      t.string :name
      t.string :location

      t.timestamps
    end
  end
end
