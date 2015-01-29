Sequel.migration do
  up do
    create_table(:deploy_logs) do
      primary_key :id

      column :order,        Integer, null: false
      column :command,      String,               text: true
      column :status,       Integer, null: false
      column :elapsed_time, Float,   null: false
      column :log,          String,               text: true

      foreign_key :deploy_id,   :deployes
    end
  end

  down do
    drop_table(:deploy_logs)
  end
end
