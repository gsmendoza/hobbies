feature 'Edit task' do
  include_context 'task_page'

  let(:edit_page) do
    Napybara::Element.new(self) do |page|
      page.finder :form, 'form' do |form|
        form.finder :weight, '#task_weight'
        form.finder :submit_button, 'input[type=submit]'

        def form.task
          Task.find(node[:id].split('_').last)
        end
      end
    end
  end

  let(:task) { create(:task) }
  let(:new_weight) { task.weight * 2 }

  Steps "user can edit a task" do
    Given "a task" do
      task
    end

    When "I view the task" do
      task_page.visit(task)
    end

    Then "I should see a link to edit the task" do
      expect(task_page.task).to have_edit_link
    end

    When "I follow the link" do
      task_page.task.edit_link.node.click
    end

    Then "I should see a page to edit the task" do
      expect(edit_page.form.task).to eq(task)
    end

    When "I submit changes to the task" do
      edit_page.form.weight.node.set(new_weight)
      edit_page.form.submit_button.node.click
    end

    Then "I should see that the task is updated" do
      expect(task_page.task.value).to eq(task)
      expect(task_page.task.weight.value).to eq(new_weight)
    end
  end
end
