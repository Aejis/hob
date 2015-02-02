Sequel.migration do
  up do
    create_table(:users) do
      primary_key :id

      column :login,        String, null: false
      column :name,         String
      column :password,     String
      column :github_name,  String, unique: true
      column :github_token, String
      column :approved,     TrueClass, default: false
      column :admin,        TrueClass, default: false
    end
  end

  down do
    drop_table(:users)
  end
end
