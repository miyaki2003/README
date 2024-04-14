class EventsController < ApplicationController
  def index
    #before_action :require_login
    @events = Event.all
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    @event.start_time = "#{params[:event][:start_date]} #{params[:event][:start_time]}"
    @event.end_time = "#{params[:event][:end_date]} #{params[:event][:end_time]}"
    @event.notify_time = "#{params[:event][:notify_date]} #{params[:event][:notify_time]}"
    respond_to do |format|
      if @event.save
        schedule_line_notification if params[:event][:line_notify] == "1"
        format.html { redirect_to events_url, notice: 'Event was successfully created.' }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('event_form', partial: "events/form", locals: { event: Event.new })
        end
      else
        format.html { render :index, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('error_explanation', partial: 'shared/error_messages', locals: { object: @event })
        end
      end
    end
  end

  private

  def event_params
    params.require(:event).permit(:title, :line_notify)
  end

  def schedule_line_notification
    notification_time =  DateTime.new(@event.start_time.year, @event.start_time.month, @event.start_time.day, params[:event][:notify_time_hour].to_i, params[:event][:notify_time_minute].to_i)
    NotificationJob.set(wait_until: notification_time).perform_later(@event.id)
  end
  
  def calculate_notification_time(start_time, notify_before_str)
    hours = notify_before_str[/(\d+)\s*時間/, 1].to_i
    minutes = notify_before_str[/(\d+)\s*分/, 1].to_i
    start_time - hours.hours - minutes.minutes
  end
end
