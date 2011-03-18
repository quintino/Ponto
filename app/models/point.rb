class Point < ActiveRecord::Base
  belongs_to :user

  attr_accessor :month, :minutes, :hours, :left, :positive, :holiday, :manual, :work_days, :hour_days, :diff
  attr_reader :month, :minutes, :hours, :left, :positive, :holiday, :manual, :work_days, :hour_days, :diff
end
