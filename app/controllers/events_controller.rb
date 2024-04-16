class EventsController < ApplicationController
  def index
    @events = Event.all
    @event = Event.new
  end

  def create
    #@event = current_user.events.build(event_params)
    @event = Event.new(event_params)
    @event.start_time = "#{params[:event][:start_date]} #{params[:event][:start_time]}"
    @event.end_time = "#{params[:event][:end_date]} #{params[:event][:end_time]}"
    @event.notify_time = "#{params[:event][:notify_date]} #{params[:event][:notify_time]}"
    respond_to do |format|
      if @event.save
        schedule_line_notification if params[:event][:line_notify] == "1"
        format.json { render json: @event, status: :created }
      else
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def details
    @event = Event.find(params[:id])
      render json: {
      id: @event.id,
      title: @event.title,
      start: @event.start_time,
      end: @event.end_time
    }
  end

  def destroy
    @event = Event.find(params[:id])
    if @event.nil?
      render json: { error: "Event not found." }, status: :not_found
    elsif @event.destroy
      render json: { success: true }, status: :ok
    else
      render json: { error: "Failed to delete the event." }, status: :unprocessable_entity
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
