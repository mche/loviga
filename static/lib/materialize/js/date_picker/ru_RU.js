// Russian

jQuery.extend( jQuery.fn.pickadate.defaults, {
    monthsFull: [ 'января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря' ],
    "месяц": [ 'январь', 'февраль', 'март', 'апрель', 'май', 'июнь', 'июль', 'август', 'сентябрь', 'октябрь', 'ноябрь', 'декабрь' ],
    monthsShort: [ 'янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек' ],
    weekdaysFull: [ 'воскресенье', 'понедельник', 'вторник', 'среда', 'четверг', 'пятница', 'суббота' ],
    weekdaysShort: [ 'вс', 'пн', 'вт', 'ср', 'чт', 'пт', 'сб' ],
    weekdaysLetter: [ 'Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб' ],
    today: 'сегодня',
    clear: 'удалить',
    labelMonthNext: 'Следующий месяц',
    labelMonthPrev: 'Предыдущий месяц',
    close: 'х',
    firstDay: 1,
    format: 'cccc dddd, d mmmm yyyy г.',
    today: 'сегодня',
    tomorrow: 'завтра',
    yesterday: 'вчера',
    formatSubmit: 'yyyy-mm-dd',
    showMonthsShort: false,
    closeOnSelect: true,
    //~ min: new Date(),
    hiddenName: true
});

jQuery.extend( jQuery.fn.pickatime.defaults, {
    clear: '',
    format: 'HH:i',
    formatLabel: function(time) { return  'HH:i'; },
    formatSubmit: 'HH:i',
    hiddenName: true,
    //~ klass: {listItem: 'picker__list-item center'},
    table: true
});
