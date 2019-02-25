class AddGravatarEnabledToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :gravatar_enabled, :boolean, default: true, null: false
  end
end
