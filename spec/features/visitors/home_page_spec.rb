# Feature: Home page
#   As a visitor
#   I want to visit a home page
#   So I can learn more about the website
feature 'Home page' do
  let(:home_page) do
    Napybara::Element.new(self) do |page|
      page.finder :task_item, 'li.task' do |task_item|
        task_item.finder :root, 'li:first-child' do |root|
          def root.value
            Task.find(node['data-id'])
          end
        end

        task_item.finder :leaf, 'li:last-child' do |leaf|
          def leaf.value
            Task.find(node['data-id'])
          end

          leaf.finder :show_link, 'a[data-name="show"]'

          leaf.finder :mark_as_done_link, 'a[data-name="mark-as-done"]'
        end
      end
    end
  end

  let(:show_task_page) do
    Napybara::Element.new(self) do |page|
      def page.visit!(task)
        node.visit node.task_path(task)
      end

      page.finder :task, '.task' do |task|
        def task.value
          Task.find(node['data-id'])
        end

        task.finder :status, '.status .value' do |status|
          def status.value
            Status.find_by_name(node.text)
          end
        end

        task.finder :last_done_on, '.last-done-on .value' do |last_done_on|
          def last_done_on.value
            node.text.to_date
          end
        end

        task.finder :done_count, '.done-count .value' do |done_count|
          def done_count.value
            node.text.to_i
          end
        end
      end
    end
  end

  let(:root_task) do
    create(:root_task, children: todo_tasks)
  end

  let(:todo_tasks) do
    [create(:todo_task), create(:todo_task)]
  end

  let(:first_recommended_task_item) do
    home_page.task_item.leaf
  end

  let(:first_recommended_task_item_value) do
    first_recommended_task_item.value
  end

  Steps 'visit the home page' do
    Given "I am a visitor"

    And 'I have a root task' do
      root_task
    end

    And 'the root task has two doable subtasks' do
      todo_tasks
    end

    When "I visit the home page" do
      visit root_path
    end

    Then 'I should see the root task' do
      expect(home_page.task_item.root.value).to eq(root_task)
    end

    And 'I should see one of the subtasks underneath it' do
      expect(root_task.children).to include(first_recommended_task_item.value)

      # cache first_recommended_task_item_value
      first_recommended_task_item_value
    end

    And 'I should see a link to mark the subtask as Done' do
      expect(first_recommended_task_item).to have_mark_as_done_link
    end

    When 'I click the Mark as Done link' do
      first_recommended_task_item.mark_as_done_link.node.click
    end

    Then 'I should see the other subtask' do
      expect(home_page.task_item.leaf.value)
        .to_not eq(first_recommended_task_item_value)
    end

    When 'I view the subtask on its own page' do
      show_task_page.visit!(first_recommended_task_item_value)
    end

    Then "I should see that it's been updated as Done" do
      task = show_task_page.task
      expect(task.value).to eq(first_recommended_task_item_value)
      expect(task.status.value).to eq(Status::DONE)
      expect(task.last_done_on.value).to eq(Date.current)
      expect(task.done_count.value).to eq(1)
    end
  end
end
