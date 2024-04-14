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

            let modal = new bootstrap.Modal(document.getElementById('eventModal'), {
              keyboard: true
            });
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

          let modal = new bootstrap.Modal(document.getElementById('eventModal'), {
            keyboard: true
          });
          modal.show();
    
          lastClickedElement = info.dayEl;
        }
      },

      eventClick: function(info) {
        info.jsEvent.preventDefault();
        document.getElementById('eventDetailsTitle').textContent = 'タイトル： ' + info.event.title;
        document.getElementById('eventDetailsStart').textContent = '開始時間： ' + info.event.start.toLocaleTimeString('ja-JP', {
          hour: 'numeric',
          minute: '2-digit',
          hour12: false
        });
        document.getElementById('eventDetailsEnd').textContent = '終了時間： ' + (info.event.end ? info.event.end.toLocaleTimeString('ja-JP', {
          hour: 'numeric',
          minute: '2-digit',
          hour12: false
      }) : '終了時間未設定');

      if (info.event.extendedProps.line_notify) {
        document.getElementById('eventNotifyTime').style.display = 'block';
        document.getElementById('eventNotifyTime').textContent = '通知： ' + info.event.extendedProps.notify_time;
      } else {
        document.getElementById('eventNotifyTime').style.display = 'none';
      }
        
        let modal = new bootstrap.Modal(document.getElementById('eventDetailsModal'));
        modal.show();
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
