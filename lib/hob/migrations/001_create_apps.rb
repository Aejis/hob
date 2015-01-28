Sequel.migration do
  up do
    create_table(:apps) do
      primary_key :id

      column :name,             String, null: false
      column :repo,             String, null: false
      column :branch,           String, null: false
      column :ruby_version,     String, null: false
      column :prepare_commands, String,              text: true
      column :run_commands,     String, null: false, text: true
    end
  end

  down do
    drop_table(:apps)
  end
end