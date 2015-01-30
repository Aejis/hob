Sequel.migration do
  up do
    create_table(:deploys) do
      primary_key :id

      column :app_name,     String,    null: false
      column :revision,     String
      column :is_success,   TrueClass, default: false
      column :elapsed_time, Float

      column :started_at,  :timestamp, null: false
      column :finished_at, :timestamp
    end
  end

  down do
    drop_table(:deploys)
  end
end
