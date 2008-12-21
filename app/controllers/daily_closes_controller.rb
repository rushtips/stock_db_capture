class DailyClosesController < ApplicationController
  make_resourceful do
    actions :all
  end

  def reload
  end

  def begin_load
    num_workers = session[:num_workers] = params[:num_workers].to_i
    process_groups = DailyClose.catchup_to_date(Date.yesterday).in_groups(num_workers, false)
    session[:daily_close_job_keys] = []
    1.upto(num_workers).each do |i|
      session[:daily_close_job_keys] << MiddleMan.new_worker(:class => :load_historical_quotes_worker,
                                                             :args => { :end_date => Date.yesterday,
                                                                        :worker_array => process_groups[i-1] })
    end
    render_js do |page|
      1.upto(num_workers).each do |i|
        page.insert_html :after, 'progress_bars', "<div id='progressbar_#{i}' class='progress'></div>"
      end
    end
  end

  def progress
    progress_percent = Array.new(session[:num_workers])
    1.upto(session[:num_workers]) do |i|
      progress_percent[i-1] = ((MiddleMan.get_worker(session[:daily_close_job_keys][i-1]).progress)*100).round
    end
    render_js do |page|
      1.upto(session[:num_workers]) do |i|
        page.call('progressPercent', "progressbar_#{i}", progress_percent[i-1])
      end
    end
  end
end
