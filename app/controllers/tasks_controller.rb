class TasksController < ApplicationController
  include TaskControllerConcerns

  def create
    @task = Task.new(task_params)
    @task.status = Status::READY

    if @task.save
      flash[:notice] = "Task created!"
      redirect_to task_path(@task)
    else
      render 'new'
    end
  end

  def destroy
    @task = Task.find(params[:id])
    @task.destroy

    flash[:notice] = "Task deleted!"

    if @task.root?
      redirect_to root_path
    else
      redirect_to task_path(@task.parent)
    end
  end

  def edit
    @task = Task.find(params[:id])
  end

  def update
    @task = Task.find(params[:id])

    if @task.update_attributes(task_params)
      flash[:notice] = "Task updated!"
      redirect_to task_path(@task)
    else
      render 'edit'
    end
  end

  def mark_as_done
    task = Task.find(params[:id])
    task.mark_as_done

    flash[:notice] = "Task #{task.name} marked as done"

    redirect_to :back
  end

  def new
    @task = Task.new
  end

  def show
    @task = Task.find(params[:id])
  end
end
