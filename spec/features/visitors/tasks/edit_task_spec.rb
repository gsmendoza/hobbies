require 'rails_helper'

RSpec.feature 'Edit task' do
  include_context 'task_page'

  shared_examples 'can change the value of the field' do
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
        change_value_of_field
        edit_page.form.submit_button.node.click
      end

      Then "I should see that the task is updated" do
        expect(task_page.task.value).to eq(task)
        expect_that_field_was_updated
      end
    end
  end

  let(:edit_page) do
    Napybara::Element.new(self) do |page|
      page.finder :form, 'form' do |form|
        form.finder :parent_id, '#task_parent_id'
        form.finder :weight, '#task_weight'
        form.finder :submit_button, 'input[type=submit]'

        def form.task
          Task.find(node[:id].split('_').last)
        end
      end
    end
  end

  let!(:task) { create(:task) }

  context 'when the field edited is the weight' do
    let(:new_value) { task.weight * 2 }

    def change_value_of_field
      edit_page.form.weight.node.set(new_value)
    end

    def expect_that_field_was_updated
      expect(task_page.task.weight.value).to eq(new_value)
    end

    it_behaves_like 'can change the value of the field'
  end

  context 'when the field edited is the parent' do
    let!(:new_parent) { create(:task) }

    def change_value_of_field
      edit_page.form.parent_id
        .node.find(:option, new_parent.ancestry_path_as_string).select_option
    end

    def expect_that_field_was_updated
      expect(task_page.task.parent.value).to eq(new_parent)
    end

    it_behaves_like 'can change the value of the field'
  end
end
