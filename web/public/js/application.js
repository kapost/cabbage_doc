$(document).ready(function()
{
  $('.controller .resource a').click(function()
  {
    $(this).closest('.controller').find('.actions').toggleClass('hidden');
  });

  $('.controller .action .subresource a').click(function()
  {
    $(this).closest('.action').find('form').toggleClass('hidden');
  });

  $('.controller .action form .add').click(function(e)
  {
    var el = $(this);
    var td = el.closest('td');

    var text = $('<input>');
    text.attr('type', 'text');
    text.attr('name', el.attr('data-name') + '[]');

    text.insertBefore(el);

    td.find('.remove').removeClass('hidden');
  });

  $('.controller .action form .remove').click(function(e)
  {
    var el = $(this);
    var td = el.closest('td');

    td.find('input[type=text]:last').remove();

    if(td.find('input[type=text]').length == 0)
      el.addClass('hidden');
  });

  $('.controller .action form .clear').click(function(e)
  {
    var el = $(this);
    var form = el.closest('form');
 
    var response = form.find('.response');
    response.addClass('hidden');

    response.find('.url').html('');
    response.find('.query').html('');
    response.find('.code').html('');
    response.find('.headers').html('');
    response.find('.body').html('');

    el.addClass('hidden');
  });

  $('.controller .action form input[type=submit]').click(function(e)
  {
    e.preventDefault();

    var form = $(this).closest('form');

    var data = $('.authentication form').serializeArray().concat(form.serializeArray());

    data.push({'name': 'method', 'value': form.attr('method') || ''});
    data.push({'name': 'action', 'value': form.attr('action') || ''});

    data = $.grep(data, function(v, i) { return v.value.length > 0; });

    $.ajax('/', {
      data: $.param(data),
      method: 'POST',
      dataType: 'json',
      complete: function(data)
      {
        var json = data.responseJSON || {};

        var response = form.find('.response');
        response.removeClass('hidden');

        response.find('.url').html(json.url);
        response.find('.query').html(json.query);
        response.find('.code').html(json.code);
        response.find('.headers').html(json.headers);
        response.find('.body').html(json.body);

        form.find('.clear').removeClass('hidden');
      },
    });

    return false;
  });
});
