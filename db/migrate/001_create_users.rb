class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :login,                     :string
      t.column :email,                     :string
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
      t.column :remember_token,            :string
      t.column :remember_token_expires_at, :datetime
      t.column :school_name,               :string
      t.column :self_intro,                :text
    end

    create_table :sessions do |t|
      t.string :session_id, :null => false
      t.text :data
      t.timestamps
    end

    add_index :sessions, :session_id
    add_index :sessions, :updated_at

    add_index :attachments, :attachable_type

    add_index :comments, :topic_id
    add_index :comments, :topic_type
    add_index :comments, :user_id

    add_index :contents, :lesson_id
    add_index :contents, :course_id

    add_index :contests, :type_id
    add_index :contests, :prize_id
    add_index :contests, :sponsor_id

    add_index :courses, :teacher_id

    add_index :fulfillments, :task_id
    add_index :fulfillments, :user_id

    add_index :groups, :course_id

    add_index :homeworks, :lesson_id
    add_index :homeworks, :problem_id

    add_index :lessons, :author_id

    add_index :memberships, :group_id
    add_index :memberships, :user_id

    add_index :pages, :user_id

    add_index :problems, :user_id
    add_index :problems, :contest_id
    add_index :problems, :problem_type_id

    add_index :problem_languages, :problem_id
    add_index :problem_languages, :language_id

    add_index :problem_tests, :problem_id

    add_index :results, :solution_id
    add_index :results, :test_id

    add_index :solutions, :user_id
    add_index :solutions, :problem_id

    add_index :users, :login
  end

  def self.down
    remove_index :attachments, :attachable_type

    remove_index :comments, :topic_id
    remove_index :comments, :topic_type
    remove_index :comments, :user_id

    remove_index :contents, :lesson_id
    remove_index :contents, :course_id

    remove_index :contests, :type_id
    remove_index :contests, :prize_id
    remove_index :contests, :sponsor_id

    remove_index :courses, :teacher_id

    remove_index :fulfillments, :task_id
    remove_index :fulfillments, :user_id

    remove_index :groups, :course_id

    remove_index :homeworks, :lesson_id
    remove_index :homeworks, :problem_id

    remove_index :lessons, :author_id

    remove_index :memberships, :group_id
    remove_index :memberships, :user_id

    remove_index :pages, :user_id

    remove_index :problems, :user_id
    remove_index :problems, :contest_id
    remove_index :problems, :problem_type_id

    remove_index :problem_languages, :problem_id
    remove_index :problem_languages, :language_id

    remove_index :problem_tests, :problem_id

    remove_index :results, :solution_id
    remove_index :results, :test_id

    remove_index :solutions, :user_id
    remove_index :solutions, :problem_id

    remove_index :users, :login

    drop_table :users
    drop_table :sessions
  end
end
