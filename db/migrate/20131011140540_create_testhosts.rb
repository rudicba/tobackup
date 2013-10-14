class CreateTesthosts < ActiveRecord::Migration
  def change
    create_table :testhosts do |t|
      t.string :name
      t.string :ip
      t.string :status

      t.timestamps
    end
  end
end
