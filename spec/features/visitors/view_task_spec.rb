feature 'View task' do
  include_context 'task_page'

  context "task has children" do
    let(:task) { create(:task) }
    let(:child_task) { create(:task, parent: task) }

    Steps "user can drill down children" do
      Given "a task has a child" do
        expect(task.reload.children).to eq([child_task])
      end

      When "I view the task" do
        task_page.visit(task)
      end

      Then "I can see the child of the task" do
        expect(task_page.task.child_tasks.first.value).to eq(child_task)
      end

      When "I follow the link to the child" do
        task_page.task.child_tasks.first.task_link.node.click
      end

      Then "I can view the child" do
        expect(task_page.task.value).to eq(child_task)
      end
    end
  end

  context "task has parent" do
    let(:parent_task) { create(:task) }
    let(:task) { create(:task, parent: parent_task) }

    Steps "user can view parent" do
      Given "a task has a parent" do
        expect(task.parent).to eq(parent_task)
      end

      When "I view the task" do
        task_page.visit(task)
      end

      Then "I can see the parent of the task" do
        expect(task_page.task.ancestors.last.value).to eq(parent_task)
      end

      When "I follow the link to the parent" do
        task_page.task.ancestors.last.task_link.node.click
      end

      Then "I can view the parent" do
        expect(task_page.task.value).to eq(parent_task)
      end
    end
  end
end
