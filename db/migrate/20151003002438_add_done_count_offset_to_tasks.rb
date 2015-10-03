class AddDoneCountOffsetToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :done_count_offset, :integer, null: false, default: 0
  end
end
