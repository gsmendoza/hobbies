require 'rails_helper'

RSpec.describe Task, type: :model do
  describe '#valid?' do
    let(:done_count) { 3 }
    let(:weight) { 6 }

    it "sets the adjusted_weight" do
      task = build(:task)

      task.done_count = done_count
      task.weight = weight

      task.valid?

      expect(task.adjusted_weight).to eq(weight / done_count)
    end
  end

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
