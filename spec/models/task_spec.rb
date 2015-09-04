require 'rails_helper'

RSpec.describe Task, type: :model do
  describe '#save' do
    context "with minimal attributes" do
      it "will save the task" do
        task = Task.new
        task.status = Status::READY
        task.name = 'Some task'

        expect(task).to be_valid

        task.save!
      end
    end

    context "with all attributes set" do
      let(:parent_task) { create(:task) }
      let(:reference_task) { create(:task) }

      it "will save the task" do
        task = Task.new
        task.parent = parent_task
        task.status = Status::READY
        task.last_done_on = Date.current
        task.done_count = 1
        task.weight = 2
        task.reference = reference_task
        task.name = 'Some task'
        task.goal = 'Some goal'

        expect(task).to be_valid

        task.save!
      end
    end
  end
end
