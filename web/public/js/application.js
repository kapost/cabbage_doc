$(document).ready(function()
{
  function compose_path(path)
  {
    return [window.location.pathname, path].join('/').replace(/\/\/+/, '/');
  }

  function submit_buttons()
  {
    return $('.controller .action form input[type=submit]');
  }

  function disable_submit_buttons()
  {
    submit_buttons().attr('disabled', true);
  }

  function enable_submit_buttons()
  {
    submit_buttons().attr('disabled', false);
  }

  function display_response(form, data)
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

    enable_submit_buttons();
  }

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

    var input = td.find('input[type=text]:first');

    if(input.length == 0) input = td.find('select:first');
    if(input.length == 0) return;

    var new_input = input.clone();

    new_input.attr('disabled', false);
    new_input.removeClass('hidden');

    new_input.insertBefore(el);

    td.find('.remove').removeClass('hidden');
  });

  $('.controller .action form .remove').click(function(e)
  {
    var el = $(this);
    var td = el.closest('td');

    td.find('input[type=text]:last').remove();
    td.find('select:last').remove();

    if(td.find('input[type=text]').length == 1 || td.find('select').length == 1)
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

    disable_submit_buttons();

    var form = $(this).closest('form');

    var data = $('.authentication form').serializeArray().concat(form.serializeArray());

    data.push({'name': 'method', 'value': form.attr('method') || ''});
    data.push({'name': 'action', 'value': form.attr('action') || ''});

    data = $.grep(data, function(v, i)
    {
      if(v.name.match(/\[hash\]$/))
      {
          var kv = v.value.split('=');
          if(kv.length == 2)
          {
            v.name = v.name.replace(/\[hash\]$/, '[' + $.trim(kv[0]) + ']');
            v.value = $.trim(kv[1]);
          }
      }

      return v.value.length > 0;
    });

    function retry_later(form, id, retries)
    {
      if(retries == 0)
      {
        display_response(form, {});
        return;
      }

      setTimeout(function()
      {
        $.ajax(compose_path('/' + id), {
          method: 'GET',
          dataType: 'json',
          complete: function(data)
          {
            if(data.status == 503)
              retry_later(form, id, retries - 1);
            else
              display_response(form, data);
          }
        });
      }, 1000);
    }

    $.ajax(compose_path('/'), {
      data: $.param(data),
      method: 'POST',
      dataType: 'json',
      complete: function(data)
      {
        var json = data.responseJSON || {};

        if(data.status == 503 && typeof json.id != 'undefined')
          retry_later(form, json.id, 30);
        else
          display_response(form, data);
      }
    });

    return false;
  });
});
