require 'rails_helper'

RSpec.feature 'Add child task' do
  include_context 'task_page'

  let(:add_child_page) do
    Napybara::Element.new(self) do |page|
      page.finder :form, 'form' do |form|
        form.finder :name, '#task_name'
        form.finder :weight, '#task_weight'
        form.finder :submit_button, 'input[type=submit]'

        def form.task
          Task.find(node[:action].split('/')[2])
        end
      end
    end
  end

  let(:task) { create(:task) }
  let(:child_task_name) { 'A child task' }
  let(:child_task_weight) { 1 }

  Steps "user can add a child to a task" do
    Given "a task" do
      task
    end

    When "I view the task" do
      task_page.visit(task)
    end

    Then "I should see a link to add a child to the task" do
      expect(task_page.task).to have_add_child_link
    end

    When "I follow the link" do
      task_page.task.add_child_link.node.click
    end

    Then "I should see a page to add a child to the task" do
      expect(add_child_page.form.task).to eq(task)
    end

    When "I submit changes to the task" do
      add_child_page.form.name.node.set(child_task_name)
      add_child_page.form.weight.node.set(child_task_weight)
      add_child_page.form.submit_button.node.click
    end

    Then "I should see that the task is updated" do
      expect(task_page.task.parent.value).to eq(task)
      expect(task_page.task.name.value).to eq(child_task_name)
      expect(task_page.task.weight.value).to eq(child_task_weight)
    end
  end
end
