require 'spec_helper'

RSpec.describe 'tasks/new' do
  subject { Capybara.string(rendered) }

  let(:task) { build(:task) }

  before do
    assign :task, task
    render
  end

  it "doesn't display the parent field" do
    expect(subject).to_not have_css('#task_parent_id')
  end
end
