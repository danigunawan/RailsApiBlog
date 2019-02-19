class CreateSiteSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :site_subscriptions do |t|
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
