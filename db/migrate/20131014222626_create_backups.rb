class CreateBackups < ActiveRecord::Migration
  def change
    create_table :backups do |t|
      t.string :path
      t.string :status
      t.datetime :last
      t.references :user, index: true
      t.references :host, index: true

      t.timestamps
    end
  end
end
