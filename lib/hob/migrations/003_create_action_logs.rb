Sequel.migration do
  up do
    create_table(:action_logs) do
      primary_key :id

      column :command,      String,               text: true
      column :status,       Integer, null: false
      column :elapsed_time, Float,   null: false
      column :log,          String,               text: true

      foreign_key :action_id, :actions
    end
  end

  down do
    drop_table(:action_logs)
  end
end
