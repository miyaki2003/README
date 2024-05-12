json.array!(@events) do |event|
  json.id event.id
  json.title event.title
  json.start event.start_time  
  json.end event.end_time
  json.line_notify event.line_notify
  if event.line_notify && event.notify_time.present?
    json.notify_time event.notify_time.strftime("%H:%M")
  else
    json.notify_time nil
  end
end