class Task < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions

  has_closure_tree

  belongs_to_active_hash :status

  belongs_to :parent, class_name: 'Task'
  belongs_to :reference, class_name: 'Task'

  scope :todo, -> { where(status: Status::TODO) }

  def self.doable
    where("not(status_id = :status_id and last_done_on = :last_done_on)",
      status_id: Status::DONE.id,
      last_done_on: Date.current)
  end

  def choose_doable_leaf_task
    find_doable_leaf_task || mark_leaf_task_todo
  end

  def find_doable_leaf_task
    leaves.todo.first
  end

  def mark_leaf_task_todo
    mark_todo
    child_task = random_doable_child_task

    if child_task
      child_task.mark_leaf_task_todo
    else
      self
    end
  end

  def mark_as_done
    self.status = Status::DONE
    save!

    parent.mark_as_done if parent

    self
  end

  def mark_todo
    self.status = Status::TODO
    self.save!

    self
  end

  def random_doable_child_task
    children.doable.order_by_rand_weighted(:weight).first
  end
end
