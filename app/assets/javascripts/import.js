function calculate_width(value, max) {
    return ((value / max) * 100).toFixed(1);
};

function span_text(width, message) {
    return width + '% (' + message + ')';
};

function format_width(width) {
    return 'width: ' + width + '%';
};

$(document).ready(function(){
    $('.progress').hide();$("#import_data").on("submit", function() {
        $('.progress').show();
    });

});

PrivatePub.subscribe('/import/status', function(data, channel) {
    var success_width = calculate_width(data.successes, data.file_size);
    var failures_width = calculate_width(data.failures, data.file_size);
    $('.progress-bar.progress-bar-success').attr('style', format_width(success_width));
    $('.progress-bar.progress-bar-warning.progress-bar-striped').attr('style', format_width(failures_width));
    $('.progress-bar.progress-bar-success').html(span_text(success_width, 'imported'));
    $('.progress-bar.progress-bar-warning.progress-bar-striped').html(span_text(failures_width, 'skipped'));
})