import { Calendar } from '@fullcalendar/core';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import listPlugin from '@fullcalendar/list';
import bootstrap5Plugin from '@fullcalendar/bootstrap5';
import jaLocale from '@fullcalendar/core/locales/ja';
import interactionPlugin from '@fullcalendar/interaction';


import 'bootstrap/dist/css/bootstrap.min.css';
// import 'bootstrap-icons/font/bootstrap-icons.css';

document.addEventListener('DOMContentLoaded', async function() {
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

  let addEventModal = new bootstrap.Modal(document.getElementById('addEventModal'), {
    keyboard: true
  });

  let settingEventModal = new bootstrap.Modal(document.getElementById('settingEventModal'), {
    keyboard: true
  });

  let eventDetailsModal = new bootstrap.Modal(document.getElementById('eventDetailsModal'), {
    keyboard: true
  });

  let editEventModal = new bootstrap.Modal(document.getElementById('editEventModal'), {
    keyboard: true
  });

  
 // 祝日
 let holidays = {};
  
 async function fetchHolidays(year) {
   let url = `https://holidays-jp.github.io/api/v1/${year}/date.json`;
   try {
     let response = await fetch(url);
     if (!response.ok) {
       throw new Error('Failed to fetch holidays');
     }
     return await response.json();
   } catch (error) {
     console.error('Error fetching holidays:', error);
     return {};
   }
 }

 async function fetchAndStoreHolidays(startYear, endYear) {
   for (let year = startYear; year <= endYear; year++) {
       holidays[year] = await fetchHolidays(year);
   }
 }

  await fetchAndStoreHolidays(2015, 2029);

  // 今日の日付を設定
  function getFormattedDate(date) {
    let year = date.getFullYear();
    let month = date.getMonth() + 1;
    let day = date.getDate();
    return `${year}-${month.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`;
  }
  let today = new Date();
  let formattedDate = getFormattedDate(today);

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
// イベントリセット
  document.getElementById('addEventModal').addEventListener('hidden.bs.modal', function () {
    document.getElementById('title-add').value = '';
    document.getElementById('event_date-add').value = formattedDate;
    document.getElementById('start_time-add').value = '18:00';
    document.getElementById('end_time-add').value = '23:59'; 
    document.getElementById('notify_time-add').value = '06:00';
    if (document.getElementById('line-notify-switch-add').checked) {
      document.getElementById('line-notify-switch-add').click();
    }
  });

  let form = document.getElementById('event-form');
  let addForm = document.getElementById('event-form-add');

  let editNotifySwitch = document.getElementById('edit-line-notify-switch');
  let editNotifyTimeInput = document.getElementById('edit-notify-time-input');
  let notifySwitch = document.getElementById('line-notify-switch');
  let notifyTimeInput = document.getElementById('notify-time-input');
  let notifySwitchAdd = document.getElementById('line-notify-switch-add');
  let notifyTimeInputAdd = document.getElementById('notify-time-input-add');
  let notifyTime = document.getElementById('notify_time');
  let notifyTimeAdd = document.getElementById('notify_time-add');
  // 追加
  let notifySwitchEdit = document.getElementById('edit-line-notify-switch');
  let notifyTimeInputEdit = document.getElementById('edit-notify-time-input');

  // 不要
  // let eventForm = document.getElementById('event-form');

  function toggleNotifyTimeInput() {
    notifyTimeInput.style.display = notifySwitch.checked ? 'block' : 'none';
  }

  function toggleNotifyTimeInputAdd() {
    notifyTimeInputAdd.style.display = notifySwitchAdd.checked ? 'block' : 'none';
  }

  // 追加
  function toggleEditNotifyTimeInput() {
    notifyTimeInputEdit.style.display = notifySwitchEdit.checked ? 'block' : 'none';
  }

  // // edit通知時間設定
  // function toggleEditNotifyTimeInput() {
  //   if (editNotifySwitch.checked) {
  //       editNotifyTimeInput.style.display = 'block';
  //       if (!editNotifyTimeInput.value) {
  //           editNotifyTimeInput.value = '06:00';
  //       }
  //   } else {
  //       editNotifyTimeInput.style.display = 'none';
  //       editNotifyTimeInput.value = '06:00';
  //   }
  // }

  document.getElementById('line-notify-switch').addEventListener('change', toggleNotifyTimeInput);
  $('#eventModal').on('show.bs.modal', toggleNotifyTimeInput);

  // AddEvent Modal用スイッチ
  document.getElementById('line-notify-switch-add').addEventListener('change', toggleNotifyTimeInputAdd);
  $('#addEventModal').on('show.bs.modal', toggleNotifyTimeInputAdd);

  // edit　Modal
  editNotifySwitch.addEventListener('change', toggleEditNotifyTimeInput);
  $('#editEventModal').on('show.bs.modal', toggleEditNotifyTimeInput);
  

  if (calendarEl) {
    let calendar = new Calendar(calendarEl, {
      timeZone: 'Asia/Tokyo',
      height: "auto",
      plugins: [ interactionPlugin, dayGridPlugin, timeGridPlugin, listPlugin, bootstrap5Plugin ],
      themeSystem: 'bootstrap5',
      locale: 'ja',
      initialView: 'dayGridMonth',
      selectable: true,
      eventSources: ['/events.json'],

      customButtons: {
        lineButton: {
          click: function() {
            window.location.href = 'https://line.me/R/ti/p/%40083jbanw';
          }
        },
        CustomButton: {
          click: function() {
            settingEventModal.show();
          }
        },   
        CalendarButton: {
          click: function() {
            addEventModal.show();
          }
        }
      },

      // 祝日
      dayCellDidMount: function(info) {
        let date = info.date;
        let year = date.getFullYear();
        let month = (date.getMonth() + 1).toString().padStart(2, '0');
        let day = date.getDate().toString().padStart(2, '0');
        let dateStr = `${year}-${month}-${day}`;
    
        if (holidays[year] && holidays[year][dateStr]) {
            let dayNumberLink = info.el.querySelector('.fc-daygrid-day-number');
            if (dayNumberLink) {
                dayNumberLink.classList.add('holiday-number');
            }
        }
    },

      eventContent: function(arg) {
        return { html: arg.event.title };
      },
      
      dayCellContent: function(arg){
        return arg.date.getDate();
      },

      dateClick: function(info) {
        fetch(`/events?date=${info.dateStr}`)
        .then(response => {
          if (!response.ok) {
            throw new Error('Network response was not ok');
          }
          return response.json();
        })
        .then(events => {
          if (events.length >= 4) {
            swal({
              title: "予定の上限です",
              text: "この日にはすでに4件のイベントが存在します",
              icon: "error",
              buttons: {
                confirm: "OK"
              },
              dangerMode: true,
              className: "custom-swal"
            });
          } else {
            document.getElementById('start_date').value = info.dateStr;
            document.getElementById('end_date').value = info.dateStr;
            document.getElementById('notify_date').value = info.dateStr;

            handleDateClick(info);
          }
        })
        .catch(error => console.error('Error:', error));
      },

      eventClick: function(info) {
        info.jsEvent.preventDefault();
        if (lastClickedElement) {
          lastClickedElement.style.backgroundColor = '';
          lastClickedElement = null;
        }
        fetchEventDetails(info.event.id);
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
      let formData = new FormData(form);
  
      if (notifySwitch.checked) {
        let notifyDateTime = new Date(formData.get('notify_date') + 'T' + formData.get('notify_time'));
        if (notifyDateTime <= new Date()) {
          alert('通知時間は現在時刻よりも後に設定してください');
          return;
        }
      }

      let searchParams = new URLSearchParams();
      for (let pair of formData.entries()) {
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
          alert('エラーが発生しました');
        } else {
          
          calendar.refetchEvents();
          form.reset();
          modal.hide();
        }
      })
      .catch(error => console.error('Error:', error));
    });

    // 追加イベントフォームの送信処理
    addForm.addEventListener('submit', function(event) {
      event.preventDefault();
      let formData = new FormData(addForm);

      if (document.getElementById('line-notify-switch-add').checked) {
        let notifyDateTime = new Date(formData.get('notify_date') + 'T' + formData.get('notify_time-add'));
        if (notifyDateTime <= new Date()) {
          alert('通知時間は現在時刻よりも後に設定してください');
          return;
        }
      }

      let searchParams = new URLSearchParams();
      for (let pair of formData.entries()) {
        searchParams.append(pair[0], pair[1]);
      }

      fetch(addForm.action, {
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
          alert('エラーが発生しました');
        } else {
          calendar.refetchEvents();
          addForm.reset();
          addEventModal.hide();
        }
      })
      .catch(error => console.error('Error:', error));
    });

    // イベント削除
    document.getElementById('delete-event').addEventListener('click', function() {
      let eventId = this.getAttribute('data-event-id');
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
            alert('イベントの削除に失敗しました');
          }
        }).catch(error => {
          console.error('Error:', error);
        });
    });

    // 編集モーダル
    document.getElementById('editEventBtn').addEventListener('click', function () {
      let eventId = this.getAttribute('data-event-id');
      console.log('Editing event ID:', eventId); 
      let startTimeText = document.getElementById('eventDetailsStart').textContent.replace('開始時間： ', '');
      let endTimeText = document.getElementById('eventDetailsEnd').textContent.replace('終了時間： ', '');
    
      document.getElementById('edit-start_time').value = formatTimeToInputValue(startTimeText);
      document.getElementById('edit-end_time').value = formatTimeToInputValue(endTimeText);
    
      document.getElementById('edit-title').value = document.getElementById('eventDetailsTitle').textContent.replace('タイトル： ', '');
      let memoContent = document.getElementById('memoContent').textContent.trim();
      document.getElementById('edit-memo').value = memoContent;
    
      let notifyTimeDisplay = document.getElementById('eventNotifyTime').style.display;
      let notifyTimeField = document.getElementById('edit-notify_time');
    
      if (notifyTimeDisplay !== 'none') {
        let notifyTimeText = document.getElementById('eventNotifyTime').textContent.replace('通知時間： ', '');
        notifyTimeField.value = formatTimeToInputValue(notifyTimeText);
      } else {
        notifyTimeField.value = '06:00';
      }
    
      let notifySwitchEdit = document.getElementById('edit-line-notify-switch');
      notifySwitchEdit.checked = notifyTimeDisplay !== 'none';

      document.getElementById('save-event-button').setAttribute('data-event-id', eventId);

      eventDetailsModal.hide();
      editEventModal.show();
    });
    
    function formatTimeToInputValue(timeText) {
      let [hours, minutes] = timeText.split(':');
      hours = hours.padStart(2, '0');
      return `${hours}:${minutes}`;
    }

    // update
    document.getElementById('save-event-button').addEventListener('click', function () {
      let eventId = this.getAttribute('data-event-id');
      let form = document.getElementById('edit-event-form');
      let formData = new FormData(form);
      
    
      fetch(`/events/${eventId}`, {
        method: 'PATCH',
        body: formData,
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        }
      })
      .then(response => {
        if (!response.ok) throw new Error('Network response was not ok.');
        return response.json();
      })
      .then(data => {
        console.log('Success:', data);
        $('#editEventModal').modal('hide');
        calendar.refetchEvents();
      })
      .catch(error => {
        console.error('Error:', error);
        alert('イベントの更新に失敗しました');
      });
    });

    






    document.getElementById('eventDetailsModal').addEventListener('hidden.bs.modal', function () {
      document.getElementById('memoContent').textContent = '';
    });

  
    let lineButtonEl = document.querySelector('.fc-lineButton-button');
    if (lineButtonEl) {
      let icon = document.createElement("i");
      icon.className = "fa-brands fa-line";
      icon.style.fontSize = '40px';
      lineButtonEl.appendChild(icon);
    }

    let CustomButtonEl = document.querySelector('.fc-CustomButton-button');
    if (CustomButtonEl) {
      let icon = document.createElement("i");
      icon.className = "fa-solid fa-gear";
      icon.style.fontSize = '25px';
      CustomButtonEl.appendChild(icon);
    }

    let CalendarButtonEl = document.querySelector('.fc-CalendarButton-button');
    if (CalendarButtonEl) {
      let icon = document.createElement("i");
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
    document.getElementById('eventDetailsEnd').textContent = `終了時間： ${formatTime(data.end)}`;
    let memoElement = document.getElementById('eventMemo');
    let memoContent = document.getElementById('memoContent');
    if (data.memo) {
        memoElement.style.display = 'block';
        memoContent.textContent = data.memo;
    } else {
        memoElement.style.display = 'none';
    }
    updateNotificationTime(data);
    showModal(data);
  }
  
  function formatTime(time) {
    return new Date(time).toLocaleTimeString('ja-JP', {
      hour: 'numeric', minute: '2-digit', hour12: false
    });
  }
  
  function updateNotificationTime(data) {
    let notifyTimeElement = document.getElementById('eventNotifyTime');
    if (data.line_notify) {
      notifyTimeElement.style.display = 'block';
      notifyTimeElement.textContent = `通知時間： ${formatTime(data.notify_time)}`;
    } else {
      notifyTimeElement.style.display = 'none';
    }
  }
  
  function showModal(data) {
    eventDetailsModal.show();
    document.getElementById('delete-event').setAttribute('data-event-id', data.id);
    document.getElementById('editEventBtn').setAttribute('data-event-id', data.id);
  }
  
  function handleEventError(error) {
    console.error('Error loading the event details:', error);
    alert('Failed to load event details: ' + error.message);
  }
});
