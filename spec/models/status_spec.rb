RSpec.describe Status do
  describe '.all' do
    it 'are Ready, Todo, Done' do
      expect(Status.all).to eq(
        [Status::READY, Status::TODO, Status::DONE])
    end
  end
end
