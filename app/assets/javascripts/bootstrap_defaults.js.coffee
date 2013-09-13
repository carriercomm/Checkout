jQuery ->
  $('a[rel=popover]').popover()
  $('div.sidebar-nav ul li a[rel=tooltip]').tooltip({ placement: 'right', container: 'li' })
  $('a[rel=tooltip]').tooltip()
  $('span[rel=tooltip]').tooltip()
  $('button[rel=tooltip]').tooltip()