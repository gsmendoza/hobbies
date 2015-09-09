module TaskControllerConcerns
  private

  def task_params
    params[:task].permit(:goal, :name, :reference_id, :weight)
  end
end
