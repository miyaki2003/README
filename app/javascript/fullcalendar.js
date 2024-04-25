import { Calendar } from '@fullcalendar/core';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import listPlugin from '@fullcalendar/list';
import bootstrap5Plugin from '@fullcalendar/bootstrap5';
import jaLocale from '@fullcalendar/core/locales/ja';
import interactionPlugin from '@fullcalendar/interaction';


import 'bootstrap/dist/css/bootstrap.min.css';
// import 'bootstrap-icons/font/bootstrap-icons.css';

document.addEventListener('DOMContentLoaded', function() {
  // ツールチップ
  let tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
  let tooltipList = tooltipTriggerList.map(function(tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl);
  });
  let lastClickedElement = null;
  let calendarEl = document.getElementById('calendar');
  let modal = new bootstrap.Modal(document.getElementById('eventModal'), {
    keyboard: true
  });

  async function fetchHolidays(year) {
    const url = `https://holidays-jp.github.io/api/v1/${year}/date.json`;
    try {
      const response = await fetch(url);
      if (!response.ok) {
        throw new Error('Failed to fetch holidays');
      }
      return await response.json();
    } catch (error) {
      console.error('Error fetching holidays:', error);
      return {};
    }
  }

// モーダルを閉じた時のイベントリセット
  document.getElementById('eventModal').addEventListener('hidden.bs.modal', function () {
    document.getElementById('title').value = '';
    document.getElementById('start_date').value = '18:00';
    document.getElementById('end_date').value = '23:59'; 
    document.getElementById('notify_time').value = '06:00';
    if (document.getElementById('line-notify-switch').checked) {
      document.getElementById('line-notify-switch').click();
    }
  });

  let form = document.getElementById('event-form');

  const notifySwitch = document.getElementById('line-notify-switch');
  const notifyTimeInput = document.getElementById('notify-time-input');
  const notifyTime = document.getElementById('notify_time');
  const eventForm = document.getElementById('event-form');

  function toggleNotifyTimeInput() {
    notifyTimeInput.style.display = notifySwitch.checked ? 'block' : 'none';
  }

  notifySwitch.addEventListener('change', toggleNotifyTimeInput);
  $('#eventModal').on('show.bs.modal', toggleNotifyTimeInput);
  toggleNotifyTimeInput();

  if (calendarEl) {
    let calendar = new Calendar(calendarEl, {
      height: "auto",
      plugins: [ interactionPlugin, dayGridPlugin, timeGridPlugin, listPlugin, bootstrap5Plugin ],
      themeSystem: 'bootstrap5',
      locale: 'ja',
      initialView: 'dayGridMonth',
      selectable: true,

      eventSources: [
        {
          events: async function(fetchInfo, successCallback, failureCallback) {
            try {
              const year = fetchInfo.start.getFullYear();
              const holidays = await fetchHolidays(year);
              const holidayEvents = Object.entries(holidays).map(([date, name]) => ({
                title: name,
                start: date,
                allDay: true,
                color: 'bule'
              }));
              successCallback(holidayEvents);
            } catch (error) {
              failureCallback(error);
            }
          }
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

        handleDateClick(info);
      },

      eventClick: function(info) {
        info.jsEvent.preventDefault();
        if (lastClickedElement) {
          lastClickedElement.style.backgroundColor = '';
          lastClickedElement = null;
        }
        fetchEventDetails(info.event.id);
      },

      customButtons: {
        lineButton: {
          click: function() {
            window.location.href = 'https://line.me/R/ti/p/%40083jbanw';
          }
        },
        CustomButton: {
          click: function() {
            // window.location.href = 'http://localhost:3000/';
          }
        },
        CalendarButton: {
          click: function() {
            // window.location.href = 'http://localhost:3000/';
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
  // datechlick
  function handleDateClick(info) {
    if (window.matchMedia("(pointer: coarse)").matches) {
      if (lastClickedElement === info.dayEl) {
        
        modal.show();
    
        modal._element.addEventListener('hidden.bs.modal', function() {
          info.dayEl.style.backgroundColor = '';
          lastClickedElement = null;
        });
      } else {
        updateDayElementBackground(info);
      }
    } else {
      modal.show();
      lastClickedElement = info.dayEl;
    }
  }
  
  function updateDayElementBackground(info) {
    if (lastClickedElement) {
      lastClickedElement.style.backgroundColor = '';
    }
    info.dayEl.style.backgroundColor = '#e3f6f5';
    lastClickedElement = info.dayEl;
  }

// eventchlick
  function fetchEventDetails(eventId) {
    fetch(`/events/${eventId}/details`)
      .then(handleResponse)
      .then(updateUIWithEventDetails)
      .catch(handleEventError);
  }
  
  function handleResponse(response) {
    if (!response.ok) {
      throw new Error('Network response was not ok');
    }
    return response.json();
  }
  
  function updateUIWithEventDetails(data) {
    document.getElementById('eventDetailsTitle').textContent = `タイトル： ${data.title}`;
    document.getElementById('eventDetailsStart').textContent = `開始時間： ${formatTime(data.start)}`;
    document.getElementById('eventDetailsEnd').textContent = `終了時間： ${data.end ? formatTime(data.end) : '終了時間未設定'}`;
    updateNotificationTime(data);
    showModal(data);
  }
  
  function formatTime(time) {
    return new Date(time).toLocaleTimeString('ja-JP', {
      hour: 'numeric', minute: '2-digit', hour12: false
    });
  }
  
  function updateNotificationTime(data) {
    const notifyTimeElement = document.getElementById('eventNotifyTime');
    if (data.line_notify) {
      notifyTimeElement.style.display = 'block';
      notifyTimeElement.textContent = `通知時間： ${formatTime(data.notify_time)}`;
    } else {
      notifyTimeElement.style.display = 'none';
    }
  }
  
  function showModal(data) {
    const modal = new bootstrap.Modal(document.getElementById('eventDetailsModal'));
    modal.show();
    document.getElementById('delete-event').setAttribute('data-event-id', data.id);
  }
  
  function handleEventError(error) {
    console.error('Error loading the event details:', error);
    alert('Failed to load event details: ' + error.message);
  }
});
