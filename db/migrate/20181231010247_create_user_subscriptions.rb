class CreateUserSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :user_subscriptions do |t|
      t.references :follower, null: false, index: true, foreign_key: {to_table: :users}
      t.references :following, null: false, index: true, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end
