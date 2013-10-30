class CreateCfiles < ActiveRecord::Migration
  def change
    create_table :cfiles do |t|
      t.string :path
      t.datetime :date
      t.references :backup, index: true

      t.timestamps
    end
  end
end
