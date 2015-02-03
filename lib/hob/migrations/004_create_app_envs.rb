Sequel.migration do
  up do
    create_table(:app_envs) do
      primary_key :id

      column :key,   String, null: false, unique: true
      column :value, String, null: false

      foreign_key :app_name, :apps, key: :name, type: String, on_update: :cascade
    end
  end

  down do
    drop_table(:app_envs)
  end
end
