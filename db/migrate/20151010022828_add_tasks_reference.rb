class AddTasksReference < ActiveRecord::Migration
  def change
    add_column :tasks, :reference, :text
  end
end
