class CalendarsController < ApplicationController
  def index
    @start_date = Date.today
  end
end
