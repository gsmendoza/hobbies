class VisitorsController < ApplicationController
  def index
    @root_tasks = Task.roots.order('name')
  end
end
