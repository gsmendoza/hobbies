FactoryGirl.define do
  factory :task do
    sequence(:name) { |n| "Task #{n}" }
    status Status::READY

    factory :root_task do
      parent nil
    end
  end
end
