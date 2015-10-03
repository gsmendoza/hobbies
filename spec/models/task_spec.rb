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
        task.done_count = 3
        task.weight = 6
        task.reference = reference_task
        task.name = 'Some task'
        task.goal = 'Some goal'

        expect(task).to be_valid

        task.save!
      end
    end

    context 'when the task is new' do
      let(:parent_task) { nil }
      let(:weight) { 16 }
      let(:task) { build(:task, weight: weight, parent: parent_task) }

      context 'when the task has siblings' do
        let!(:parent_task) { create(:task) }

        let!(:sibling_tasks) do
          [
            create(:task, parent: parent_task, done_count: 8),
            create(:task, parent: parent_task, done_count: 1)
          ]
        end

        let(:sibling_with_lowest_offsetted_done_count) { sibling_tasks[0] }

        let(:expected_offsetted_done_count) do
          sibling_with_lowest_offsetted_done_count.done_count +
            sibling_with_lowest_offsetted_done_count.done_count_offset
        end

        before do
          parent_task.reload
          expect(parent_task.children).to eq(sibling_tasks)

          expect(sibling_tasks[0].offsetted_done_count).to eq(8)
          expect(sibling_tasks[1].offsetted_done_count).to eq(9) # 8 + 1
        end

        it "sets the done count offset to the lowest offsetted done count of its
          siblings".squish do
          task.save!

          expect(task.done_count_offset).to eq(expected_offsetted_done_count)
        end

        it "sets the adjusted_weight" do
          task.save!

          expect(task.adjusted_weight)
            .to eq(weight.to_f / expected_offsetted_done_count)
        end
      end

      context "when the task doesn't have siblings" do
        before do
          expect(task.siblings).to be_empty
        end

        it "sets the done count offset to zero" do
          task.save!

          expect(task.done_count_offset).to eq(0)
        end
      end
    end

    context 'when the task is not new' do
      let(:done_count) { 3 }
      let(:weight) { 60 }

      let(:task) do
        create(:task, done_count: done_count, weight: weight)
      end

      it "sets the adjusted_weight" do
        task.save!

        expect(task.done_count_offset).to eq(0)
        expect(task.adjusted_weight).to eq(weight.to_f / done_count)
      end
    end
  end

  describe '#choose_doable_leaf_task' do
    let(:task) { Task.new }
    let(:result) { instance_double('Task') }

    context "when the task has a doable leaf task" do
      before do
        expect(task).to receive(:find_doable_leaf_task).and_return(result)
      end

      it 'should return the doable leaf task' do
        expect(task.choose_doable_leaf_task).to eq(result)
      end
    end

    context "when the task doesn't have a doable leaf task" do
      before do
        expect(task).to receive(:find_doable_leaf_task).and_return(nil)
        expect(task).to receive(:mark_leaf_task_todo).and_return(result)
      end

      it 'makes a leaf task doable' do
        expect(task.choose_doable_leaf_task).to eq(result)
      end
    end
  end

  describe '#find_doable_leaf_task' do
    let!(:task) { create(:task) }
    let!(:child_task) { create(:task, parent: task) }

    let!(:grandchild_task) do
      create(:task, parent: child_task, status: Status::TODO)
    end

    it "returns a leaf task of the task with a todo status" do
      expect(task.find_doable_leaf_task).to eq(grandchild_task)
    end
  end

  describe '#mark_leaf_task_todo' do
    let(:task) { build(:task, status: Status::READY, children: child_tasks) }

    context "when the task has a random doable child task" do
      let(:child_task) { build(:task) }
      let(:child_tasks) { [child_task] }

      before do
        expect(task).to receive(:random_doable_child_task).and_return(child_task)
      end

      it "marks the task TODO" do
        expect(task).to receive(:mark_todo)
        task.mark_leaf_task_todo
      end

      it "marks a leaf task of a random doable child of the task as TODO" do
        expect(child_task).to receive(:mark_leaf_task_todo)
        task.mark_leaf_task_todo
      end
    end

    context "when the task has no random doable child task" do
      let(:child_task) { build(:task) }
      let(:child_tasks) { [child_task] }

      before do
        expect(task).to receive(:random_doable_child_task).and_return(nil)
      end

      it "marks the task TODO" do
        expect(task).to receive(:mark_todo)
        task.mark_leaf_task_todo
      end
    end
  end

  describe '#mark_todo' do
    let(:task) { build(:task, status: Status::READY) }

    it "sets the status of the task to todo" do
      result = task.mark_leaf_task_todo

      expect(result).to eq(task)
      expect(result.persisted?).to be_truthy
      expect(result.status).to eq(Status::TODO)
    end
  end

  describe '#random_doable_child_task' do
    let!(:task) { create(:task) }

    let(:last_done_on) { Date.current }

    let!(:child_task) do
      create(:task,
        parent: task,
        last_done_on: last_done_on,
        status: status)
    end

    before do
      task.reload
    end

    context "when the only child was done" do
      let(:status) { Status::DONE }

      context "today" do
        let(:last_done_on) { Date.current }

        it "returns nil" do
          expect(task.random_doable_child_task).to eq(nil)
        end
      end

      context "before today" do
        let(:last_done_on) { Date.yesterday }

        it "returns the child" do
          expect(task.random_doable_child_task).to eq(child_task)
        end
      end
    end

    context "when the only child is not done" do
      let(:status) { Status::TODO }

      it "returns the child" do
        expect(task.random_doable_child_task).to eq(child_task)
      end
    end
  end

  describe "#mark_as_done" do
    let!(:task) { create(:task, status: Status::READY) }
    let!(:child_task) { create(:task, parent: task, status: Status::READY) }

    it "marks itself and its ancestors as done" do
      child_task.mark_as_done

      aggregate_failures do
        expect(child_task.status).to eq(Status::DONE)
        expect(child_task.last_done_on).to eq(Date.current)
        expect(child_task.done_count).to eq(1)
        expect(child_task.changes).to be_empty

        expect(task.status).to eq(Status::DONE)
        expect(task.last_done_on).to eq(Date.current)
        expect(task.done_count).to eq(1)
        expect(task.changes).to be_empty
      end
    end
  end
end
