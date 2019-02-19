class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.string :content
      t.references :user, index: true, foreign_key: true
      t.references :article, index: true, foreign_key: true
      t.references :comment, index: true, foreign_key: 'comment_id' # Rails 5, reference + index + column name in one line
      t.timestamps
    end
  end
end
