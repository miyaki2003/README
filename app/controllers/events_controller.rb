class EventsController < ApplicationController
  def index
    #before_action :require_login
    @events = Event.all
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    if @event.save
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
    params.require(:event).permit(:title, :start, :end_time)
  end
end
