class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :name, null: false
      t.integer :reference_id
      t.string :goal
      t.integer :weight, null: false, default: 1
      t.integer :parent_id
      t.integer :status_id, null: false
      t.date :last_done_on
      t.integer :done_count, null: false, default: 0

      t.timestamps null: false
    end
  end
end
