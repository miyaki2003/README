class EventsController < ApplicationController
  def index
    #before_action :require_login
    @events = Event.all 
  end
  def new
    @event = Event.new
    render plain: render_to_string(partial: 'form_new', layout: false, locals: { event: @event })
  end

  def create
    @event = Event.new(params_event)
    if @event.save
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.js
      end
    else
      respond_to do |format|
        format.js { render partial: "shared/error_messages", locals: { object: @event } }
      end
    end
  end

  def params_event
      params.require(:event).permit(:title, :start, :end_time)
  end
end
