require 'rails_helper'

RSpec.describe "Users", type: :system do
  let(:user) { FactoryBot.create(:user) }

  describe 'ログイン前' do
    describe 'ユーザー新規登録' do
      context 'フォームの入力値が正常' do
        it 'ユーザーの新規作成が成功する' do
          visit new_user_path
          expect {
            fill_in 'Email', with: 'newuser@exapmle.com'
            fill_in 'Password', with: 'password'
            fill_in 'Password confirmation', with: 'password'
            click_button 'SignUp'
          }.to change { User.count }.by(1)
          expect(current_path).to eq login_path
          expect(page).to have_content('User was successfully created.')
        end
      end
      context 'メールアドレスが未入力' do
        it 'ユーザーの新規作成が失敗する' do
          visit new_user_path
          expect {
            fill_in 'Email', with: nil
            fill_in 'Password', with: 'password'
            fill_in 'Password confirmation', with: 'password'
            click_button 'SignUp'
          }.to change { User.count }.by(0)
          expect(current_path).to eq users_path
          expect(page).to have_content("Email can't be blank")
        end
      end
      context '登録済のメールアドレスを使用' do
        it 'ユーザーの新規作成が失敗する' do
          existing_email_user = FactoryBot.create(:user)
          visit new_user_path
          expect {
            fill_in 'Email', with: existing_email_user.email
            fill_in 'Password', with: 'password'
            fill_in 'Password confirmation', with: 'password'
            click_button 'SignUp'
          }.to change { User.count }.by(0)
          expect(current_path).to eq users_path
          expect(page).to have_content("Email has already been taken")
        end
      end
    end

    describe 'マイページ' do
      context 'ログインしていない状態' do
        it 'マイページへのアクセスが失敗する' do
          visit user_path(user)
          expect(current_path).to eq login_path
          expect(page).to have_content("Login required")
        end
      end
    end
  end

  describe 'ログイン後' do
    before { login_as(user) }
    describe 'ユーザー編集' do
      context 'フォームの入力値が正常' do
        it 'ユーザーの編集が成功する' do
          visit edit_user_path(user)
          fill_in 'Email', with: 'update@runteq.org'
          fill_in 'Password', with: 'update_password'
          fill_in 'Password confirmation', with: 'update_password'
          click_button 'Update'
          expect(current_path).to eq user_path(user)
          expect(page).to have_content('User was successfully updated.')
        end
      end
      context 'メールアドレスが未入力' do
        it 'ユーザーの編集が失敗する' do
          visit edit_user_path(user)
          fill_in 'Email', with: ''
          fill_in 'Password', with: 'update_password'
          fill_in 'Password confirmation', with: 'update_password'
          click_button 'Update'
          expect(current_path).to eq user_path(user)
          expect(page).to have_content("Email can't be blank")
        end
      end
      context '登録済のメールアドレスを使用' do
        it 'ユーザーの編集が失敗する' do
          existing_user = FactoryBot.create(:user)
          visit edit_user_path(user)
          fill_in 'Email', with: existing_user.email
          fill_in 'Password', with: 'update_password'
          fill_in 'Password confirmation', with: 'update_password'
          click_button 'Update'
          expect(current_path).to eq user_path(user)
          expect(page).to have_content("Email has already been taken")
        end
      end
      context '他ユーザーの編集ページにアクセス' do
        it '編集ページへのアクセスが失敗する' do
          other_user = FactoryBot.create(:user)
          visit edit_user_path(other_user.id)
          expect(current_path).to eq user_path(user)
          expect(page).to have_content("Forbidden access")
        end
      end
    end

    describe 'マイページ' do
      context 'タスクを作成' do
        it '新規作成したタスクが表示される' do
          visit new_task_path
          fill_in 'Title', with: 'new_task_title'
          fill_in 'Content', with: 'new_task_content'
          select 'doing', from: 'task[status]'
          click_button 'Create Task'
          visit user_path(user)
          expect(page).to have_content('You have 1 task.')
          expect(page).to have_content('new_task_title')
          expect(page).to have_content('doing')
          expect(page).to have_link('Show')
          expect(page).to have_link('Edit')
          expect(page).to have_link('Destroy')
        end
      end
    end
  end
end
