json.array!(@events) do |event|
  json.id event.id
  json.title event.title
  json.start event.start_time  
  json.end event.end_time
  json.line_notify event.line_notify
  json.notify_time event.notify_time.strftime("%H:%M") if event.line_notify
end