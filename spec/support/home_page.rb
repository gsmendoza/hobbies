shared_context 'home_page' do
  let(:home_page) do
    Napybara::Element.new(self) do |page|
      def page.visit
        node.visit node.root_path
      end

      page.finder :add_task_link, 'a.add-task'

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
end
