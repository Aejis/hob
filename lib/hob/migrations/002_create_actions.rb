Sequel.migration do
  up do
    create_table(:actions) do
      primary_key :id

      column :app_name,     String,    null: false
      column :type,         String,    null: false
      column :requested_by, String,    null: false
      column :number,       String,    null: false
      column :revision,     String
      column :is_success,   TrueClass, default: false
      column :elapsed_time, Float

      column :started_at,  :timestamp, null: false
      column :finished_at, :timestamp
    end
  end

  down do
    drop_table(:actions)
  end
end
