# Feature: Home page
#   As a visitor
#   I want to visit a home page
#   So I can learn more about the website
feature 'Home page' do
  Steps 'visit the home page' do
    Given "I am a visitor"

    And 'I have a root task' do
      create(:root_task)
    end

    And 'the root task has two doable subtasks'

    When "I visit the home page" do
      visit root_path
    end

    Then 'I should see the root task'

    And 'I should see one of the subtasks underneath it'

    And 'I should see a link to mark the subtask as Done'

    When 'I click the Mark as Done link'

    Then 'I should no longer see the subtask'

    And 'instead I see the other subtask'

    When 'I view the subtask on its own page'

    Then "I should see that it's been updated as Done"

    skip
  end
end
