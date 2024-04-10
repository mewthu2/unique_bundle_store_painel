class RunSchedulerJob < ApplicationJob
  queue_as :default

  def perform
    Rails.application.load_tasks
    Rake::Task['scheduler:thirty_days'].invoke
    Rake::Task['scheduler:seven_days'].invoke
  end
end
