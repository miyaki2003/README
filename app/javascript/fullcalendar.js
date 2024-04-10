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

      events: [
          {
              title  : 'イベント1',
              start  : '2023-04-10T14:30:00',
              end    : '2023-04-10T16:30:00',
          },
          {
              title  : 'イベント2',
              start  : '2023-04-12T10:00:00',
              end    : '2023-04-12T12:00:00',
          }
      ],

      dayCellContent: function(arg){
        return arg.date.getDate();
      },

      dateClick: function(info) {
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
        
            info.dayEl.style.backgroundColor = '#E0F2F1';
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
        let eventTitle = info.event.title;

        document.getElementById('eventModalLabel').textContent = eventTitle + " Details";

        document.getElementById('eventTitle').textContent = 'Title: ' + info.event.title;
        document.getElementById('eventStart').textContent = 'Start: ' + info.event.start.toLocaleString();
        document.getElementById('eventEnd').textContent = 'End: ' + (info.event.end ? info.event.end.toLocaleString() : 'Not set');

        document.getElementById('eventDetails').style.display = 'block';
        document.getElementById('eventEditForm').style.display = 'none';
        document.getElementById('editEventBtn').style.display = 'inline-block';
        document.getElementById('saveEventBtn').style.display = 'none';

        let modal = new bootstrap.Modal(document.getElementById('eventModal'));
        modal.show();
      },



      customButtons: {
        CustomButton: {
          text: '設定',
          click: function() {
            window.location.href = 'http://localhost:3000/';
          }
        },
        lineButton: {
          text: 'LINEへ',
          click: function() {
            window.location.href = 'http://localhost:3000/';
          }
        },
      },

      headerToolbar: {
        start: 'title',
        center: '',
        end: 'dayGridMonth timeGridWeek listWeek lineButton CustomButton'
      },
      footerToolbar: {
        left: 'prev',
        center: 'today CustomButton',
        right: 'next'
      },
      buttonIcons: {
        prev: 'chevron-left',
        next: 'chevron-right'
      },
      buttonText: {
        month: '月',
        today: '今日',
        week: '週',
        list: 'リスト',
        prev: '<i class="fa-solid fa-chevron-left"></i>',
        next: '<i class="fa-solid fa-chevron-right"></i>',
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
        timeGridWeek: {
          titleFormat: { year: 'numeric', month: 'numeric', day: 'numeric' }
        },
        listWeek: {
          titleFormat: { year: 'numeric', month: 'numeric', day: 'numeric' }
        }
      }
    });
    
    

    calendar.render();
    
  }
});
