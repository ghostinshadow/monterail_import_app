function calculate_width(value, max) {
    return ((value / max) * 100).toFixed(1);
};

function span_text(width, message) {
    return width + '% (' + message + ')';
};

function format_width(width) {
    return 'width: ' + width + '%';
};

function reset_status_bar(){
    $('.progress').hide();
    $('.progress-bar.progress-bar-success').attr('style', 0);
    $('.progress-bar.progress-bar-warning.progress-bar-striped').attr('style', 0);
    $('.progress-bar.progress-bar-success').html(span_text(0, 'imported'));
    $('.progress-bar.progress-bar-warning.progress-bar-striped').html(span_text(0, 'skipped'));
}

$(document).ready(function(){
    $('.progress').hide();
    $("#import_data").on("submit", function() {
        reset_status_bar();
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

PrivatePub.subscribe('/status/messages', function(data, channel){
    var alert = '<div class="alert alert-' + data.type + '" role="alert">' +
                JSON.stringify(data.message) +
                '<button name=\"button\" type=\"button\" aria-hidden=\"true\"' + 
                ' data-dismiss=\"alert\" class=\"close\">x</button> </div>';
    if(data.type === 'danger'){
      $('.progress').hide();
    };
    $('.flashes').html(alert);
})