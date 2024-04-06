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
        const year = info.date.getFullYear();
        const month = (info.date.getMonth() + 1);
        const day = info.date.getDate();

        $.ajax({
          type: 'GET',
          url:  '/events/new',
        }).done(function (res) {

            $('.modal-body').html(res);


            $('#event_start_1i').val(year);
            $('#event_start_2i').val(month);
            $('#event_start_3i').val(day);

            $('#event_end_1i').val(year);
            $('#event_end_2i').val(month);
            $('#event_end_3i').val(day);


            $('#modal').modal('show');
        }).fail(function (result) {

          alert("failed");
        });
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
    $(".error").click(function(){
      calendar.refetchEvents();
  });
  }
});
