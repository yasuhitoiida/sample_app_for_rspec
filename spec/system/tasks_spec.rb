require 'rails_helper'

RSpec.describe "Tasks", type: :system do
  let(:user) { FactoryBot.create(:user)}
  let(:task) { FactoryBot.create(:task)}
  context 'ログインしていない状態' do
    it 'タスク新規作成ページへのアクセスが失敗する' do
      visit new_task_path
      expect(current_path).to eq login_path
      expect(page).to have_content('Login required')
    end
    it 'タスク編集ページへのアクセスが失敗する' do
      visit edit_task_path(task)
      expect(current_path).to eq login_path
      expect(page).to have_content('Login required')
    end
  end
  describe 'ログイン後' do
    before { login_as(user) }
    describe 'タスク新規作成' do
      before { visit new_task_path }
      context '入力値が正常' do
        it 'タスクの新規作成が成功する' do
          fill_in 'Title', with: 'new_task_title'
          fill_in 'Content', with: 'new_task_content'
          select 'doing', from: 'task[status]'
          fill_in 'Deadline', with: DateTime.new(2020, 12, 31, 10, 00)
          click_button 'Create Task'
          expect(page).to have_content('Task was successfully created')
          expect(page).to have_content('new_task_title')
          expect(page).to have_content('new_task_content')
          expect(page).to have_content('doing')
          expect(page).to have_content('2020/12/31 10:0')
        end
      end
      context 'タイトルが未入力' do
        it 'タスクの新規作成が失敗する' do
          click_button 'Create Task'
          expect(page).to have_content("Title can't be blank")
        end
      end
    end
  end
  # pending "add some scenarios (or delete) #{__FILE__}"
end
