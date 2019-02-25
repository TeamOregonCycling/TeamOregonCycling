class RemoveGravatarEnabledFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :gravatar_enabled
  end
end
