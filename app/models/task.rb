class Task < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions

  has_closure_tree dependent: :destroy

  belongs_to_active_hash :status

  belongs_to :parent, class_name: 'Task'
  belongs_to :reference, class_name: 'Task'

  validates :name, presence: true

  validates :weight,
    presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :adjusted_weight,
    presence: true,
    numericality: { greater_than_or_equal_to: 0 }

  validates :status_id,
    presence: true,
    inclusion: { in: Status.all.map(&:id) }

  validates :done_count,
    presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :todo, -> { where(status: Status::TODO) }

  before_save do
    if self.new_record?
      self.done_count_offset =
        siblings.order("done_count + done_count_offset").first
          .try(:offsetted_done_count) || 0
    end

    self.adjusted_weight =
      weight.to_f / (offsetted_done_count == 0 ? 1 : offsetted_done_count)
  end

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
    self.last_done_on = Date.current
    self.done_count += 1
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
    children.doable.order_by_rand_weighted(:adjusted_weight).first
  end

  def ancestry_path_as_string
    ancestry_path.join(" / ")
  end

  def offsetted_done_count
    done_count + done_count_offset
  end
end
