import { Calendar } from '@fullcalendar/core';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import listPlugin from '@fullcalendar/list';
import bootstrap5Plugin from '@fullcalendar/bootstrap5';
import jaLocale from '@fullcalendar/core/locales/ja';
// import "./stylesheets/fullcalendar.scss";

import 'bootstrap/dist/css/bootstrap.min.css';
// import 'bootstrap-icons/font/bootstrap-icons.css';

document.addEventListener('DOMContentLoaded', function() {
  let calendarEl = document.getElementById('calendar');
  if (calendarEl) {
    let calendar = new Calendar(calendarEl, {
      plugins: [ dayGridPlugin, timeGridPlugin, listPlugin, bootstrap5Plugin ],
      googleCalendarApiKey: 'AIzaSyBVwYdLEech74tOcyT59DLpMrDkHQpZ_9g',
      events: {
        googleCalendarId: 'ja.japanese#holiday@group.v.calendar.google.com',
        className: 'event_holiday'
      },
      themeSystem: 'bootstrap5',
      locale: 'ja',
      dayCellContent: function(arg){
        return arg.date.getDate();
      },
      headerToolbar: {
        start: 'prev,next today',
        center: 'title',
        end: 'dayGridMonth,timeGridWeek,listWeek'
      },
      footerToolbar: {
        left: 'prev,next today',
        right: 'dayGridMonth,timeGridWeek,listWeek'
      },
      buttonText: {
        today: '今月',
        month: '月',
        week: '週',
        list: 'リスト'
      },
      initialView: 'dayGridMonth',
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
