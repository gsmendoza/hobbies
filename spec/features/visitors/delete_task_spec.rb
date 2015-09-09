feature 'Add child task' do
  include_context 'task_page'

  context 'when task is a root task' do
    include_context 'home_page'

    let!(:task) { create(:task) }
    let!(:child_task) { create(:task, parent: task) }

    Steps "user is redirected to the home page after deletion" do
      When "I view the task" do
        task_page.visit(task)
      end

      Then "I should see a link to delete the task" do
        expect(task_page.task).to have_delete_link
      end

      When "I follow the link" do
        task_page.task.delete_link.node.click
      end

      Then "I should see that the task has deleted" do
        expect(home_page.task_items).to be_empty
      end

      And "I should see that its descendents have also been deleted" do
        expect { child_task.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  context 'when task is not a root task' do
    scenario "user is redirected to the parent's page after deletion"
  end
end
