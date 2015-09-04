# Feature: Home page
#   As a visitor
#   I want to visit a home page
#   So I can learn more about the website
feature 'Home page' do
  Steps 'visit the home page' do
    Given "I am a visitor"

    When "I visit the home page" do
      visit root_path
    end

    Then 'I see "Welcome"' do
      expect(page).to have_content 'Welcome'
    end
  end
end
