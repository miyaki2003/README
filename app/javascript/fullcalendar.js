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

      dayCellContent: function(arg){
        return arg.date.getDate();
      },


      

      dateClick: function(info) {
        if (window.matchMedia("(pointer: coarse)").matches) {
          
          info.dayEl.style.backgroundColor = '#D3E8ED';
  
          var modal = new bootstrap.Modal(document.getElementById('eventModal'), {
              keyboard: true
          });
          modal.show();
          
          modal._element.addEventListener('hidden.bs.modal', function() {
              info.dayEl.style.borderColor = '';
              lastClickedElement = null;
          });
      } else {
          if (lastClickedElement === info.dayEl) {
            let modal = new bootstrap.Modal(document.getElementById('eventModal'), {
              keyboard: true
            });
            modal.show();
            
            modal._element.addEventListener('hidden.bs.modal', function() {
              lastClickedElement = null;
            });

          } else {
              lastClickedElement = info.dayEl;
          }
        }
      },
      
      eventClick: function(info) {
        alert('Event: ' + info.event.title);
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
        start: 'prev',
        center: 'title',
        end: 'lineButton CustomButton next'
      },
      footerToolbar: {
        left: 'today',
        center: 'dayGridMonth timeGridWeek listWeek',
        right: 'CustomButton'
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
        }
      }
    });
    
    calendar.setOption('windowResize', function() {
      if (window.innerWidth < 768) {
        calendar.changeView('listMonth');
      } else {
        calendar.changeView('dayGridMonth');
      }
    });

    calendar.render();
    
  }
});
