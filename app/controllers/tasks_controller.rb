class TasksController < ApplicationController
  def mark_as_done
    task = Task.find(params[:id])
    task.mark_as_done

    flash[:notice] = "Task #{task.name} marked as done"

    redirect_to :back
  end
end
