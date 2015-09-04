class VisitorsController < ApplicationController
  def index
    @root_tasks = Task.roots
  end
end
