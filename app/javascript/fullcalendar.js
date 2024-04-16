import { Calendar } from '@fullcalendar/core';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import listPlugin from '@fullcalendar/list';
import bootstrap5Plugin from '@fullcalendar/bootstrap5';
import jaLocale from '@fullcalendar/core/locales/ja';
import interactionPlugin from '@fullcalendar/interaction';
import googleCalendarPlugin from '@fullcalendar/google-calendar';

import 'bootstrap/dist/css/bootstrap.min.css';
// import 'bootstrap-icons/font/bootstrap-icons.css';

document.addEventListener('DOMContentLoaded', function() {
  let tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
  let tooltipList = tooltipTriggerList.map(function(tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl);
  });
  let lastClickedElement = null;
  let calendarEl = document.getElementById('calendar');
  let modal = new bootstrap.Modal(document.getElementById('eventModal'), {
    keyboard: true
  });
  let form = document.getElementById('event-form');

  const notifySwitch = document.getElementById('line-notify-switch');
  const notifyTimeInput = document.getElementById('notify-time-input');
  const notifyTime = document.getElementById('notify_time');
  const eventForm = document.getElementById('event-form');

  if (calendarEl) {
    let calendar = new Calendar(calendarEl, {
      height: "auto",
      plugins: [ interactionPlugin, dayGridPlugin, timeGridPlugin, listPlugin, bootstrap5Plugin, googleCalendarPlugin ],
      themeSystem: 'bootstrap5',
      locale: 'ja',
      initialView: 'dayGridMonth',
      selectable: true,
      googleCalendarApiKey: 'AIzaSyBEjT2zMm5yB9LYkUawhLf6A9oNt1rRWBA',
      eventSources: [
        {
          googleCalendarId: 'ja.japanese#holiday@group.v.calendar.google.com',
          className: 'event_holiday'
        },
        '/events.json'
      ],

      eventContent: function(arg) {
        return { html: arg.event.title };
      },
      
      dayCellContent: function(arg){
        return arg.date.getDate();
      },

      dateClick: function(info) {
        document.getElementById('start_date').value = info.dateStr;
        document.getElementById('end_date').value = info.dateStr;
        document.getElementById('notify_date').value = info.dateStr;
        if (window.matchMedia("(pointer: coarse)").matches) {
          if (lastClickedElement === info.dayEl) {
            
            modal.show();
        
            modal._element.addEventListener('hidden.bs.modal', function() {
              info.dayEl.style.backgroundColor = '';
              lastClickedElement = null;
            });
          } else {

            if (lastClickedElement) {
              lastClickedElement.style.backgroundColor = '';
            }
        
            info.dayEl.style.backgroundColor = '#e3f6f5';
            lastClickedElement = info.dayEl;
          }
        } else {

          modal.show();
    
          lastClickedElement = info.dayEl;
        }
      },

      eventClick: function(info) {
        info.jsEvent.preventDefault();
        fetch(`/events/${info.event.id}/details`)
          .then(response => {
            if (!response.ok) {
              throw new Error('Network response was not ok');
            }
            return response.json();
          })
          .then(data => {
            document.getElementById('eventDetailsTitle').textContent = 'タイトル： ' + data.title;
            document.getElementById('eventDetailsStart').textContent = '開始時間： ' + new Date(data.start).toLocaleTimeString('ja-JP', {
              hour: 'numeric', minute: '2-digit', hour12: false
            });
            document.getElementById('eventDetailsEnd').textContent = '終了時間： ' + (data.end ? new Date(data.end).toLocaleTimeString('ja-JP', {
              hour: 'numeric', minute: '2-digit', hour12: false
            }) : '終了時間未設定');
            
            if (data.line_notify) {
              document.getElementById('eventNotifyTime').style.display = 'block';
              document.getElementById('eventNotifyTime').textContent = '通知： ' + data.notify_time;
            } else {
              document.getElementById('eventNotifyTime').style.display = 'none';
            }
            let modal = new bootstrap.Modal(document.getElementById('eventDetailsModal'));
            modal.show();
            document.getElementById('delete-event').setAttribute('data-event-id', data.id);
          })
          .catch(error => {
            console.error('Error loading the event details:', error);
            alert('Failed to load event details: ' + error.message);
          });
        },

      customButtons: {
        lineButton: {
          click: function() {
            window.location.href = 'https://line.me/R/ti/p/%40083jbanw';
          }
        },
        CustomButton: {
          click: function() {
            window.location.href = 'http://localhost:3000/';
          }
        },
        CalendarButton: {
          click: function() {
            window.location.href = 'http://localhost:3000/';
          }
        },
      },

      headerToolbar: {
        start: 'title',
        end: 'dayGridMonth listMonth CustomButton lineButton'
      },
      footerToolbar: {
        left: 'prev',
        center: 'today CalendarButton',
        right: 'next'
      },
      buttonIcons: {
        prev: 'chevron-left',
        next: 'chevron-right'
      },
      buttonText: {
        month: '月',
        today: '今日',
        list: 'リスト',
        prev: '<',
        next: '>',
      },
      views: {
        dayGridMonth: {
          titleFormat: { year: 'numeric', month: 'numeric' },
        },
        listMonth: {
          titleFormat: { year: 'numeric', month: 'numeric' },
          listDayFormat: { month: 'numeric', day: 'numeric', weekday: 'narrow' },
          listDaySideFormat: false
        },
      }
    });

    calendar.render();

    notifySwitch.addEventListener('change', function() {
      notifyTimeInput.style.display = this.checked ? 'block' : 'none';
    });

    form.addEventListener('submit', function(event) {
      event.preventDefault();
      const formData = new FormData(form);
  
      if (notifySwitch.checked) {
        const notifyDateTime = new Date(formData.get('notify_date') + 'T' + formData.get('notify_time'));
        if (notifyDateTime <= new Date()) {
          alert('通知時間は現在時刻よりも後に設定してください。');
          return;
        }
      }

    const searchParams = new URLSearchParams();
    for (const pair of formData.entries()) {
      searchParams.append(pair[0], pair[1]);
    }

      fetch(form.action, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        body: searchParams
      })
      .then(response => response.json())
      .then(data => {
        if (data.errors) {
          alert('エラーが発生しました。');
        } else {
          
          calendar.refetchEvents();
          form.reset();
          modal.hide();
        }
      })
      .catch(error => console.error('Error:', error));
    });

    document.getElementById('delete-event').addEventListener('click', function() {
      const eventId = this.getAttribute('data-event-id');
        fetch(`/events/${eventId}`, {
          method: 'DELETE',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
          }
        }).then(response => {
          if (response.ok) {
            calendar.refetchEvents();
          } else {
            alert('イベントの削除に失敗しました。');
          }
        }).catch(error => {
          console.error('Error:', error);
        });
    });

    let lineButtonEl = document.querySelector('.fc-lineButton-button');
    if (lineButtonEl) {
      const icon = document.createElement("i");
      icon.className = "fa-brands fa-line";
      icon.style.fontSize = '40px';
      lineButtonEl.appendChild(icon);
    }

    let CustomButtonEl = document.querySelector('.fc-CustomButton-button');
    if (CustomButtonEl) {
      const icon = document.createElement("i");
      icon.className = "fa-solid fa-gear";
      icon.style.fontSize = '25px';
      CustomButtonEl.appendChild(icon);
    }

    let CalendarButtonEl = document.querySelector('.fc-CalendarButton-button');
    if (CalendarButtonEl) {
      const icon = document.createElement("i");
      icon.className = "fa-regular fa-calendar-plus";
      icon.style.fontSize = '25px';
      CalendarButtonEl.appendChild(icon);
    }
  }
});
