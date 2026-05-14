class AddCourseAndTeeTimeToRounds < ActiveRecord::Migration[5.2]
  def change
    add_column :rounds, :course_id, :integer
    add_column :rounds, :tee_time, :string
  end
end
