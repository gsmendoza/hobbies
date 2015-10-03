require 'rails_helper'

RSpec.feature 'Add root task' do
  include_context 'home_page'
  include_context 'task_page'

  let(:add_task_page) do
    Napybara::Element.new(self) do |page|
      page.finder :form, 'form' do |form|
        form.finder :name, '#task_name'
        form.finder :weight, '#task_weight'
        form.finder :submit_button, 'input[type=submit]'
      end
    end
  end

  let(:task_name) { 'A root task' }
  let(:task_weight) { 1 }

  Steps "user can add a root task" do
    When "I view the home page" do
      home_page.visit
    end

    Then "I should see a link to add a root task" do
      expect(home_page).to have_add_task_link
    end

    When "I follow the link" do
      home_page.add_task_link.node.click
    end

    When "I submit a new task" do
      add_task_page.form.name.node.set(task_name)
      add_task_page.form.weight.node.set(task_weight)
      add_task_page.form.submit_button.node.click
    end

    Then "I should see that the task is created" do
      expect(task_page.task.ancestors).to be_empty
      expect(task_page.task.name.value).to eq(task_name)
      expect(task_page.task.weight.value).to eq(task_weight)
    end
  end
end
