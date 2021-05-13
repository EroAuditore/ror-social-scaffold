require 'capybara/rspec'

RSpec.describe 'Friendship invitation', type: :system do
  before :each do
    User.create(name: 'Edu', email: 'Edu@gmail.com', password: 'konohavillage')
  end

  it 'Can add a friend' do
    visit '/users/sign_in'

    within('#new_user') do
      fill_in 'Email', with: 'louis@hotmail.com'
      fill_in 'Password', with: 'konohavillage'
    end

    click_button 'Log in'

    visit '/users'
    sleep(3)

    within '.users-section' do
      click_link('Add friend', match: :first)
    end

    sleep(5)
    expect(page).to have_content 'Pending'
    sleep(5)
  end

  it 'Can Accept a friend' do
    sleep(3)
    visit '/users/sign_in'
    sleep(3)
    within('#new_user') do
      fill_in 'Email', with: 'Edu@gmail.com'
      fill_in 'Password', with: 'konohavillage'
    end
    sleep(5)
    click_button 'Log in'

    visit '/users'
    sleep(5)

    within '.users-section' do
      click_link('Accept', match: :first)
    end

    sleep(5)
    expect(page).to have_content 'Louis is now your friend'
    sleep(5)
  end
end
