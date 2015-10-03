RSpec.shared_context 'home_page' do
  let(:home_page) do
    Napybara::Element.new(self) do |page|
      def page.visit
        node.visit node.root_path
      end

      page.finder :add_task_link, 'a.add-task'

      page.finder :task_item, 'li.task' do |task_item|
        def task_item.value
          Task.find(node['data-id'])
        end

        task_item.finder :root, 'ul.breadcrumb li:first-child' do |root|
          def root.value
            Task.find(node['data-id'])
          end
        end

        task_item.finder :show_link, 'a[data-name="show"]'

        task_item.finder :mark_as_done_link, 'a[data-name="mark-as-done"]'
      end
    end
  end
end
