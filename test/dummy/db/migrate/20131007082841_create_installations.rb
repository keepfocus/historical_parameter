class CreateInstallations < ActiveRecord::Migration
  def change
    create_table :installations do |t|

      t.timestamps
    end
  end
end
