module TaskControllerConcerns
  private

  def task_params
    params[:task].permit(:goal, :name, :parent_id, :reference, :weight)
  end
end
