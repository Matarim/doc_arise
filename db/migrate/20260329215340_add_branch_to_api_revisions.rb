class AddBranchToApiRevisions < ActiveRecord::Migration[8.1]
  def change
    add_column :api_revisions, :branch, :string, null: false, default: "main"

    # Ensure one revision_number per spec + branch
    add_index :api_revisions, [:api_specification_id, :branch, :revision_number], unique: true, name: "index_api_revisions_on_spec_branch_revision"
    add_index :api_revisions, [:api_specification_id, :branch], name: "index_api_revisions_on_spec_and_branch"
  end
end
