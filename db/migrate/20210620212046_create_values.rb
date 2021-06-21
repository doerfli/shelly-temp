class CreateValues < ActiveRecord::Migration[6.1]
  def change
    create_table :values do |t|
      t.string :value
      t.references :device, null: false, foreign_key: true
      t.references :type, null: false, foreign_key: true

      t.timestamps
    end
  end
end
