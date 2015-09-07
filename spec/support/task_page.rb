shared_context 'task_page' do
  let(:task_page) do
    Napybara::Element.new(self) do |page|
      def page.visit(task)
        node.visit node.task_path(task)
      end

      page.finder :task, '.task' do |task|
        def task.value
          Task.find(node['data-id'])
        end

        task.finder :ancestor, '.ancestor' do |ancestor|
          def ancestor.value
            Task.find(node['data-id'])
          end

          ancestor.finder :task_link, 'a.task-link'
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

        task.finder :child_task, '.child-task' do |child_task|
          def child_task.value
            Task.find(node['data-id'])
          end

          child_task.finder :task_link, 'a.task-link'
        end
      end
    end
  end
end