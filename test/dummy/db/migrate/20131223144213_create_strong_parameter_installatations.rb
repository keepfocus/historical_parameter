class CreateStrongParameterInstallatations < ActiveRecord::Migration
  def change
    create_table :strong_parameter_installations do |t|
      t.string :name
      t.timestamps
    end
  end
end
