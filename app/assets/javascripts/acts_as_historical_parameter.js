jQuery(function() {
  jQuery('.destroy_historical_value').each(function() {
    var cell = jQuery(this);
    cell.children().hide();
    var button = document.createElement("input");
    jQuery(button).attr("type", "submit");
    jQuery(button).val("Remove");
    jQuery(button).addClass("remove_historical_value_button");
    cell.append(button);
  });

  jQuery(document).on('click', '.remove_historical_value_button', function(event) {
    event.preventDefault();
    var row = jQuery(this).closest("tr");
    row.hide();
    row.find("input[type=hidden]").val(1);
  });

  jQuery('.add_historical_value').on('click', function(event) {
    var assoc   = jQuery(this).attr('data-association');
    var content = jQuery('#' + assoc + '_fields_template tbody').html();
    var regexp  = new RegExp('new_' + assoc, 'g');
    var new_id  = new Date().getTime();

    jQuery('#' + assoc + '_table tbody').append(content.replace(regexp, new_id));    
    return false;
  });
};
