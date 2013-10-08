class AddNameToInstallations < ActiveRecord::Migration
  def change
    add_column :installations, :name, :string
  end
end
