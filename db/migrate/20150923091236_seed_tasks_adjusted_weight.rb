class SeedTasksAdjustedWeight < ActiveRecord::Migration
  def up
    Task.find_each(&:save!)
  end

  def down
    # Do nothing
  end
end
