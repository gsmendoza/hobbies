class Task < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions

  has_closure_tree

  belongs_to_active_hash :status

  belongs_to :parent, class_name: 'Task'
  belongs_to :reference, class_name: 'Task'
end
