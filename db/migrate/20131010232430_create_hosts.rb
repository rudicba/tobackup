class CreateHosts < ActiveRecord::Migration
  def change
    create_table :hosts do |t|
      t.string :name
      t.string :ip
      t.string :status
      t.boolean :cygwin

      t.timestamps
    end
  end
end
