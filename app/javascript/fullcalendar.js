import { Calendar } from '@fullcalendar/core';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import listPlugin from '@fullcalendar/list';
import bootstrap5Plugin from '@fullcalendar/bootstrap5';
import jaLocale from '@fullcalendar/core/locales/ja';
import interactionPlugin from '@fullcalendar/interaction';

import 'bootstrap/dist/css/bootstrap.min.css';

var selectedDate;

document.addEventListener('DOMContentLoaded', async function() {
  // ツールチップ
  $('[data-bs-toggle="tooltip"]').tooltip();

  let lastClickedElement = null;
  let calendarEl = document.getElementById('calendar');

  let modal = new bootstrap.Modal(document.getElementById('eventModal'), { keyboard: true });
  let addEventModal = new bootstrap.Modal(document.getElementById('addEventModal'), { keyboard: true });
  let settingEventModal = new bootstrap.Modal(document.getElementById('settingEventModal'), { keyboard: true });
  let eventDetailsModal = new bootstrap.Modal(document.getElementById('eventDetailsModal'), { keyboard: true });
  let editEventModal = new bootstrap.Modal(document.getElementById('editEventModal'), { keyboard: true });

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
  $('#eventModal').on('hidden.bs.modal', function() {
    $('#title').val('');
    $('#start_date').val('18:00');
    $('#end_date').val('23:59');
    $('#notify_time').val('06:00');
    if ($('#line-notify-switch').prop('checked')) {
      $('#line-notify-switch').trigger('click')
    }
  });

  // イベントリセット
  $('#addEventModal').on('hidden.bs.modal', function() {
    $('#title-add').val('');
    $('#event_date-add').val(formattedDate);
    $('#start_time-add').val('18:00');
    $('#end_time-add').val('23:59');
    $('#notify_time-add').val('06:00');
    if ($('#line-notify-switch-add').prop('checked')) {
      $('#line-notify-switch-add').trigger('click')
    }
  });

  let form = $('#event-form');
  let addForm = $('#event-form-add');

  let notifySwitch = $('#line-notify-switch');
  let notifyTimeInput = $('#notify-time-input');
  let notifyTime = $('#notify_time');

  let notifySwitchAdd = $('#line-notify-switch-add');
  let notifyTimeInputAdd = $('#notify-time-input-add');

  let notifySwitchEdit = $('#edit-line-notify-switch');
  let notifyTimeInputEdit = $('#edit-notify-time-input');

  function toggleNotifyTimeInput() {
    notifyTimeInput.toggle(notifySwitch.prop('checked'));
  }

  function toggleNotifyTimeInputAdd() {
    notifyTimeInputAdd.toggle(notifySwitchAdd.prop('checked'));
  }

  function toggleEditNotifyTimeInput() {
    notifyTimeInputEdit.toggle(notifySwitchEdit.prop('checked'));
  }

  // スイッチ切り替え
  notifySwitch.on('change', toggleNotifyTimeInput)
  $('#eventModal').on('show.bs.modal', toggleNotifyTimeInput);

  notifySwitchAdd.on('change', toggleNotifyTimeInputAdd)
  $('#addEventModal').on('show.bs.modal', toggleNotifyTimeInputAdd);

  notifySwitchEdit.on('change', toggleEditNotifyTimeInput)
  $('#editEventModal').on('show.bs.modal', toggleEditNotifyTimeInput);

  if (calendarEl) {
    let calendar = new Calendar(calendarEl, {
      timeZone: 'Asia/Tokyo',
      height: "auto",
      plugins: [interactionPlugin, dayGridPlugin, timeGridPlugin, listPlugin, bootstrap5Plugin],
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
          let dayNumberLink = $(info.el).find('.fc-daygrid-day-number')[0];
          if (dayNumberLink) {
            dayNumberLink.classList.add('holiday-number');
          }
        }
      },

      eventContent: function(arg) {
        return { html: arg.event.title };
      },

      dayCellContent: function(arg) {
        return arg.date.getDate();
      },

      dateClick: function(info) {
        $.getJSON(`/events?date=${info.dateStr}`)
          .done(events => {
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
              $('#start_date').val(info.dateStr);
              $('#end_date').val(info.dateStr);
              $('#notify_date').val(info.dateStr);

              handleDateClick(info);
            }
          })
          .fail(error => console.error('Error:', error));
      },

      eventClick: function(info) {
        info.jsEvent.preventDefault();
        selectedDate = info.event.startStr.split('T')[0];
        $('#selected-date-display').text(selectedDate);
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

    form.on('submit', function(event) {
      event.preventDefault();
      let formData = new FormData(this);

      if (notifySwitch.prop('checked')) {
        let notifyDateTime = new Date(`${formData.get('notify_date')}T${formData.get('notify_time')}`);
        if (notifyDateTime <= new Date()) {
          Swal.fire({
            icon: 'error',
            title: "通知時間は現在時刻よりも後に設定してください",
            color: "#33333",
            timer: 1200,
            timerProgressBar: true,
            willOpen: (popup) => {
              popup.style.borderRadius = '15px';
              const confirmButton = popup.querySelector('.swal2-confirm');
              confirmButton.style.borderRadius = '10px';
            }
          });
          return;
        }
      }

      let searchParams = new URLSearchParams();
      for (let pair of formData.entries()) {
        searchParams.append(pair[0], pair[1]);
      }

      $.ajax({
        url: form.attr('action'),
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
        },
        data: searchParams.toString(),
        success: function(data) {
          if (data.errors) {
            alert('エラーが発生しました');
          } else {
            calendar.refetchEvents();
            form[0].reset();
            modal.hide();
          }
        },
        error: function(error) {
          console.error('Error:', error);
        }
      });
    });

    // 追加イベントフォームの送信処理
    addForm.on('submit', function(event) {
      event.preventDefault();
      let formData = new FormData(this);
      let eventDateAdd = $('#event_date-add').val();
      let notifyTimeAdd = $('#notify_time-add').val();

      if (notifySwitchAdd.prop('checked')) {
        let fullNotifyDateTime = new Date(`${eventDateAdd}T${notifyTimeAdd}`);
        console.log('Full Notify DateTime:', fullNotifyDateTime);

        if (fullNotifyDateTime <= new Date()) {
          Swal.fire({
            icon: 'error',
            title: "通知時間は現在時刻よりも後に設定してください",
            color: "#33333",
            timer: 1200,
            timerProgressBar: true,
            willOpen: (popup) => {
              popup.style.borderRadius = '15px';
              const confirmButton = popup.querySelector('.swal2-confirm');
              confirmButton.style.borderRadius = '10px';
            }
          });
          return;
        }
        formData.set('event[notify_date]', eventDateAdd);
        formData.set('event[notify_time]', notifyTimeAdd);
      }

      $.ajax({
        url: addForm.attr('action'),
        method: 'POST',
        headers: {
          'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
        },
        data: formData,
        processData: false,
        contentType: false,
        success: function(data) {
          if (data.errors) {
            alert('エラーが発生しました: ' + data.errors.join(', '));
          } else {
            calendar.refetchEvents();
            addForm[0].reset();
            addEventModal.hide();
          }
        },
        error: function(error) {
          console.error('Error:', error);
          Swal.fire({
            icon: 'error',
            title: "タイトルを入力してください",
            color: "#33333",
            timer: 1200,
            timerProgressBar: true,
            willOpen: (popup) => {
              popup.style.borderRadius = '15px';
              const confirmButton = popup.querySelector('.swal2-confirm');
              confirmButton.style.borderRadius = '10px';
            }
          });
        }
      });
    });

    // イベント削除
    $('#delete-event').on('click', function() {
      let eventId = $(this).data('event-id');
      $.ajax({
        url: `/events/${eventId}`,
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
        },
        success: function() {
          calendar.refetchEvents();
        },
        error: function(error) {
          alert('イベントの削除に失敗しました');
          console.error('Error:', error);
        }
      });
    });

    // 編集モーダル
    $('#editEventBtn').on('click', function() {
      let eventId = $(this).data('event-id');
      let selectedDate = $('#selected-date-display').text();
      let startTimeText = $('#eventDetailsStart').text().replace('開始時間： ', '');
      let endTimeText = $('#eventDetailsEnd').text().replace('終了時間： ', '');

      $('#edit-event_date').val(selectedDate);
      $('#edit-start_time').val(formatTimeToInputValue(startTimeText));
      $('#edit-end_time').val(formatTimeToInputValue(endTimeText));

      $('#edit-title').val($('#eventDetailsTitle').text().replace('タイトル： ', ''));
      let memoContent = $('#memoContent').text().trim();
      $('#edit-memo').val(memoContent);

      let notifyTimeDisplay = $('#eventNotifyTime').css('display');
      let notifyTimeField = $('#edit-notify_time');

      if (notifyTimeDisplay !== 'none') {
        let notifyTimeText = $('#eventNotifyTime').text().replace('通知時間： ', '');
        notifyTimeField.val(formatTimeToInputValue(notifyTimeText));
      } else {
        notifyTimeField.val('06:00');
      }
      notifySwitchEdit.prop('checked', notifyTimeDisplay !== 'none');
      toggleEditNotifyTimeInput();

      $('#save-event-button').data('event-id', eventId);

      eventDetailsModal.hide();
      editEventModal.show();
    });

    function formatTimeToInputValue(timeText) {
      let [hours, minutes] = timeText.split(':');
      hours = hours.padStart(2, '0');
      return `${hours}:${minutes}`;
    }

    // update
    $('#save-event-button').on('click', function() {
      let eventId = $(this).data('event-id');
      let form = $('#edit-event-form')[0];
      let formData = new FormData(form);

      $.ajax({
        url: `/events/${eventId}`,
        method: 'PATCH',
        headers: {
          'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
        },
        data: formData,
        processData: false,
        contentType: false,
        success: function() {
          $('#editEventModal').modal('hide');
          calendar.refetchEvents();
        },
        error: function(error) {
          console.error('Error:', error);
          alert('イベントの更新に失敗しました');
        }
      });
    });

    $('#eventDetailsModal').on('hidden.bs.modal', function() {
      $('#memoContent').text('');
    });

    let lineButtonEl = $('.fc-lineButton-button');
    if (lineButtonEl.length) {
      let icon = $('<i>', { class: 'fa-brands fa-line', style: 'font-size: 40px;' });
      lineButtonEl.append(icon);
    }

    let CustomButtonEl = $('.fc-CustomButton-button');
    if (CustomButtonEl.length) {
      let icon = $('<i>', { class: 'fa-solid fa-gear', style: 'font-size: 25px;' });
      CustomButtonEl.append(icon);
    }

    let CalendarButtonEl = $('.fc-CalendarButton-button');
    if (CalendarButtonEl.length) {
      let icon = $('<i>', { class: 'fa-regular fa-calendar-plus', style: 'font-size: 25px;' });
      CalendarButtonEl.append(icon);
    }
  }

  // dateclick
  function handleDateClick(info) {
    if (window.matchMedia("(pointer: coarse)").matches) {
      if (lastClickedElement === info.dayEl) {
        modal.show();

        $(modal._element).on('hidden.bs.modal', function() {
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
    info.dayEl.style.backgroundColor = '#F2F7FA';
    lastClickedElement = info.dayEl;
  }

  // eventclick
  function fetchEventDetails(eventId) {
    $.getJSON(`/events/${eventId}/details`)
      .done(updateUIWithEventDetails)
      .fail(handleEventError);
  }

  function updateUIWithEventDetails(data) {
    $('#eventDetailsTitle').text(`タイトル： ${data.title}`);
    $('#eventDetailsStart').text(`開始時間： ${formatTime(data.start)}`);
    $('#eventDetailsEnd').text(`終了時間： ${formatTime(data.end)}`);
    let memoElement = $('#eventMemo');
    let memoContent = $('#memoContent');
    if (data.memo) {
      memoElement.show();
      memoContent.text(data.memo);
    } else {
      memoElement.hide();
    }
    updateNotificationTime(data);
    showModal(data);
  }

  function formatTime(time) {
    return new Date(time).toLocaleTimeString('ja-JP', {
      hour: 'numeric',
      minute: '2-digit',
      hour12: false
    });
  }

  function updateNotificationTime(data) {
    let notifyTimeElement = $('#eventNotifyTime');
    if (data.line_notify) {
      notifyTimeElement.show();
      notifyTimeElement.text(`通知時間： ${formatTime(data.notify_time)}`);
    } else {
      notifyTimeElement.hide();
    }
  }

  function showModal(data) {
    eventDetailsModal.show();
    $('#delete-event').data('event-id', data.id);
    $('#editEventBtn').data('event-id', data.id);
  }

  function handleEventError(error) {
    console.error('Error loading the event details:', error);
    alert('Failed to load event details: ' + error.message);
  }
});

