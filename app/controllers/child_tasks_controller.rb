class ChildTasksController < ApplicationController
  include TaskControllerConcerns

  def create
    @parent_task = Task.find(params[:task_id])
    @task = @parent_task.children.build(task_params)
    @task.status = Status::READY

    if @task.save
      flash[:notice] = "Task created!"
      redirect_to task_path(@task)
    else
      render 'new'
    end
  end

  def new
    @parent_task = Task.find(params[:task_id])
    @task = @parent_task.children.build
  end
end
