class EventsController < ApplicationController
  def index
    @events = current_user.events
    #@events = Event.all
    @event = Event.new
  end

  def create
    @event = current_user.events.build(event_params)
    #@event = Event.new(event_params)

    @event.line_user_id = current_user.line_user_id
    set_datetime_params

    if @event.valid?
      if @event.save
        schedule_line_notification if params[:event][:line_notify] == "1"
        render json: @event, status: :created
      else
        render json: @event.errors, status: :unprocessable_entity
      end
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  def details
    @event = current_user.events.find_by(id: params[:id])
    #@event = Event.find(params[:id])
      render json: {
      id: @event.id,
      title: @event.title,
      start: @event.start_time,
      end: @event.end_time,
      notify_time: @event.notify_time,
      line_notify: @event.line_notify
    }
  end

  def destroy
    @event = current_user.events.find_by(id: params[:id])
    #@event = Event.find(params[:id])
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
    params.require(:event).permit(:title, :line_notify, :start_date, :start_time, :end_date, :end_time, :notify_date, :notify_time)
  end

  def set_datetime_params
    if params[:event][:start_date].present? && params[:event][:start_time].present?
      @event.start_time = Time.zone.parse("#{params[:event][:start_date]} #{params[:event][:start_time]}")
    end
    if params[:event][:end_date].present? && params[:event][:end_time].present?
      @event.end_time = Time.zone.parse("#{params[:event][:end_date]} #{params[:event][:end_time]}")
    end
    if params[:event][:notify_date].present? && params[:event][:notify_time].present?
      @event.notify_time = Time.zone.parse("#{params[:event][:notify_date]} #{params[:event][:notify_time]}")
    end
  end

  def schedule_line_notification
    NotificationJob.set(wait_until: @event.notify_time).perform_later(@event.id)
  end
  
  def calculate_notification_time(start_time, notify_before_str)
    hours = notify_before_str[/(\d+)\s*時間/, 1].to_i
    minutes = notify_before_str[/(\d+)\s*分/, 1].to_i
    start_time - hours.hours - minutes.minutes
  end
end
