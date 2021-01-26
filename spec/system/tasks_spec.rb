require 'rails_helper'

RSpec.describe "Tasks", type: :system do
  let(:user) { FactoryBot.create(:user)}
  let(:task) { FactoryBot.create(:task)}
  describe 'ログイン前' do
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
    it 'タスク一覧ページへのアクセスが成功する' do
      visit tasks_path
      expect(current_path).to eq tasks_path
    end
    it 'タスク詳細ページへのアクセスが成功する' do
      visit task_path(task)
      expect(current_path).to eq task_path(task)
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
          expect(current_path).to eq '/tasks/1'
        end
      end
      context 'タイトルが未入力' do
        it 'タスクの新規作成が失敗する' do
          click_button 'Create Task'
          expect(current_path).to eq tasks_path
          expect(page).to have_content("Title can't be blank")
        end
      end
      context '登録済みのタイトルを入力' do
        it 'タスクの新規作成が失敗する' do
          fill_in 'Title', with: task.title
          click_button 'Create Task'
          expect(current_path).to eq tasks_path
          expect(page).to have_content("Title has already been taken")
        end
      end
    end
    describe 'タスク編集' do
      let(:task) { FactoryBot.create(:task, user: user) }
      before { visit edit_task_path(task) }
      context '入力値が正常' do
        it 'タスク編集が成功する' do
          fill_in 'Title', with: 'update_title'
          fill_in 'Content', with: 'update_content'
          select 'done', from: 'task[status]'
          fill_in 'Deadline', with: DateTime.new(2020, 12, 15, 10, 00)
          click_button 'Update Task'
          expect(current_path).to eq task_path(task)
          expect(page).to have_content('Task was successfully updated')
          expect(page).to have_content('update_title')
          expect(page).to have_content('update_content')
          expect(page).to have_content('done')
          expect(page).to have_content('2020/12/15 10:0')
        end
      end
      context 'タイトルが未入力' do
        it 'タスク編集に失敗する' do
          fill_in 'Title', with: ''
          click_button 'Update Task'
          expect(current_path).to eq task_path(task)
          expect(page).to have_content("Title can't be blank")
        end
      end
      context '登録済みのタイトルを入力' do
        it 'タスクの編集が失敗する' do
          other_task = FactoryBot.create(:task, user:user)
          fill_in 'Title', with: other_task.title
          click_button 'Update Task'
          expect(current_path).to eq task_path(task)
          expect(page).to have_content("Title has already been taken")
        end
      end
    end
    describe 'タスク削除' do
      it 'タスクの削除が成功する' do
        task = FactoryBot.create(:task, user: user)
        visit tasks_path
        click_link 'Destroy'
        expect(page.accept_confirm).to eq 'Are you sure?'
        expect(page).to have_content 'Task was successfully destroyed'
        expect(current_path).to eq tasks_path
        expect(page).not_to have_content task.title
      end
    end
  end
end
