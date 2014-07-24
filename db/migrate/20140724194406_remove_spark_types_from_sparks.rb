class RemoveSparkTypesFromSparks < ActiveRecord::Migration
  def change
  	remove_column :sparks, :spark_type, :string
  end
end
