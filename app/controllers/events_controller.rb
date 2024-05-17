class EventsController < ApplicationController
  def index
    if params[:date]
      date = Date.parse(params[:date])
      events = current_user.events.where("DATE(start_time) = ?", date)
      #events = Event.where("DATE(start_time) = ?", date)
      render json: events, status: :ok
    else
      @events = current_user.events
      @event = current_user.events.build
      #@events = Event.all
      #@event = Event.new
    end
  end

  def create
    @event = current_user.events.build(event_params)
    #@event = Event.new(event_params)

    @event.line_user_id = current_user.line_user_id
    set_datetime_params

      if current_user.events.where("DATE(start_time) = ?", @event.start_time.to_date).count >= 4
        render json: { error: "この日は既に4件のイベントが予定されています" }, status: :unprocessable_entity
        return
      end

    #  if Event.where("DATE(start_time) = ?", @event.start_time.to_date).count >= 4
    #    render json: { error: "この日は既に4件のイベントが予定されています" }, status: :unprocessable_entity
    #    return
    #  end

    if @event.valid?
      if @event.save
        schedule_line_notification if @event.line_notify
        render json: @event, status: :created
      else
        render json: @event.errors, status: :unprocessable_entity
      end
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  def update
    @event = current_user.events.find_by(id: params[:id])
    #@event = Event.find(params[:id])
    @event.assign_attributes(event_params)
    set_datetime_params

    Rails.logger.info "Event before saving: #{@event.inspect}"
    Rails.logger.info "Attempting to cancel job with ID: #{@event.notification_job_id}"

    if @event.notification_job_id
      if cancel_job(@event.notification_job_id)
        Rails.logger.info "Old job with ID: #{@event.notification_job_id} successfully cancelled"
      else
        Rails.logger.warn "Old job with ID: #{@event.notification_job_id} could not be found"
      end
    else
      Rails.logger.info "No previous job to cancel"
    end
    
    if @event.save
      if @event.line_notify
        if schedule_line_notification
          Rails.logger.info "New job scheduled with ID: #{@event.notification_job_id}"
          render json: @event, status: :ok
        else
          render json: { error: 'Failed to schedule notification' }, status: :unprocessable_entity
        end
      else
        render json: @event, status: :ok
      end
    else
      render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def cancel_job(job_id)
    sets = [Sidekiq::ScheduledSet.new, Sidekiq::RetrySet.new, Sidekiq::Queue.new]
    sets.each do |set|
      set.each do |job|
        Rails.logger.debug "Checking job ID: #{job.jid} in #{set.name}"
      end
      job = set.find_job(job_id)
      if job
        job.delete
        Rails.logger.info "Job with ID: #{job_id} cancelled from #{set.name}"
        return true
      end
    end
    Rails.logger.info "Job with ID: #{job_id} not found in any set"
    false
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
      line_notify: @event.line_notify,
      event_date: @event.event_date,
      memo: @event.memo
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
    params.require(:event).permit(:title, :line_notify, :event_date, :start_date, :start_time, :end_date, :end_time, :notify_date, :notify_time, :memo, :notification_job_id)
  end

  def set_datetime_params
    if params[:event][:event_date].present?
      date = Time.zone.parse(params[:event][:event_date])
      @event.start_time = combine_date_and_time(date, params[:event][:start_time]) if params[:event][:start_time].present?
      @event.end_time = combine_date_and_time(date, params[:event][:end_time]) if params[:event][:end_time].present?
      if params[:event][:notify_time].present?
        @event.notify_time = combine_date_and_time(date, params[:event][:notify_time])
      end
    else
      if params[:event][:start_date].present? && params[:event][:start_time].present?
        @event.start_time = Time.zone.parse("#{params[:event][:start_date]} #{params[:event][:start_time]}")
      end
      if params[:event][:end_date].present? && params[:event][:end_time].present?
        @event.end_time = Time.zone.parse("#{params[:event][:end_date]} #{params[:event][:end_time]}")
      end
    end
    if params[:event][:notify_date].present? && params[:event][:notify_time].present?
      @event.notify_time = Time.zone.parse("#{params[:event][:notify_date]} #{params[:event][:notify_time]}")
    end
  end

  def combine_date_and_time(date, time_str)
    Time.zone.parse("#{date.strftime('%Y-%m-%d')} #{time_str}")
  end

  def schedule_line_notification
    job = NotificationJob.set(wait_until: @event.notify_time).perform_later(@event.id)
    Rails.logger.info "Scheduled new job with ID: #{job.job_id} for event ID: #{@event.id}"
    if @event.update(notification_job_id: job.job_id)
      true
    else
      Rails.logger.error "Failed to update event with new job ID"
      false
    end
  end
  
  def calculate_notification_time(start_time, notify_before_str)
    hours = notify_before_str[/(\d+)\s*時間/, 1].to_i
    minutes = notify_before_str[/(\d+)\s*分/, 1].to_i
    start_time - hours.hours - minutes.minutes
  end
end
