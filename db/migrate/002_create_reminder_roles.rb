class CreateReminderRoles < ActiveRecord::Migration[6.1]
  def self.up
    unless table_exists?(:reminder_roles)
      create_table :reminder_roles do |t|
        t.column :reminder_id, :integer
        t.column :role_id, :integer
      end
    end
  end

  def self.down
    drop_table :reminder_roles if table_exists?(:reminder_roles)
  end
end
