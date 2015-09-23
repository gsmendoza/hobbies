class AddAdjustedWeightToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :adjusted_weight, :float, null: false, default: 1
  end
end
