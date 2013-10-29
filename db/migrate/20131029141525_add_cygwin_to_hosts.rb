class AddCygwinToHosts < ActiveRecord::Migration
  def change
    add_column :hosts, :cygwin, :boolean
  end
end
