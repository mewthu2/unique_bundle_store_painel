namespace :scheduler do
  desc "Run UpdateProductSalesJob for thirty days"
  task thirty_days: :environment do
    if Date.today.day == 1
      UpdateProductSalesJob.perform_now('thirty_days')
    end
  end

  desc "Run UpdateProductSalesJob for seven days"
  task seven_days: :environment do
    if Date.today.monday?
      UpdateProductSalesJob.perform_now('seven_days')
    end
  end
end
