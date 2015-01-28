Sequel.migration do
  up do
    create_table(:deployes) do
      primary_key :id

      column :app_name,     String,    null: false
      column :revision,     String,    null: false
      column :is_success,   TrueClass, null: false
      column :elapsed_time, Float,     null: false

      column :deployed_at, :timestamp, null: false
    end
  end

  down do
    drop_table(:deployes)
  end
end