class EventsController < ApplicationController
  def index
    #before_action :require_login
    @events = Event.all
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      schedule_line_notification if params[:event][:line_notify] == "1"
      respond_to do |format|
        format.html { redirect_to events_path }
        format.turbo_stream { render turbo_stream: turbo_stream.replace('eventModal', partial: "events/form", locals: { event: Event.new }) }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace('eventModal', partial: "events/form", locals: { event: @event }) }
      end
    end
  end

  private

  def event_params
    params.require(:event).permit(:title, :start_time, :end_time, :notify_time_hour, :notify_time_minute)
  end

  def schedule_line_notification
    notification_time =  DateTime.new(@event.start.year, @event.start.month, @event.start.day, params[:event][:notify_time_hour].to_i, params[:event][:notify_time_minute].to_i)
  
    NotificationJob.set(wait_until: notification_time).perform_later(@event.id)
  end
  
  def calculate_notification_time(start_time, notify_before_str)
    hours = notify_before_str[/(\d+)\s*時間/, 1].to_i
    minutes = notify_before_str[/(\d+)\s*分/, 1].to_i
  
    start_time - hours.hours - minutes.minutes
  end
end
