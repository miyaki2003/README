class EventsController < ApplicationController
  def index
    #before_action :require_login
    @events = Event.all 
  end

  def create
    @event = Event.new(event_params)
    respond_to do |format|
      if @event.save
        format.json { render json: @event, status: :created }
      else
        format.json { render json: @event.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  private

  def event_params
    params.require(@event).permit(:title, :start, :end_time)
  end
end
