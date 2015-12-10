class AddCommentToHistoricalParameter < ActiveRecord::Migration
  def change
    add_column :historical_parameters, :comment, :string
  end
end
