resizeSidebarBackground = ->
  $(".sidebar").width $(document).width() - $(".sidebar-wrapper").position().left - 31
  contentHeight = $(".footer").position().top - $(".main-content-sidebar").position().top
  sidebarHeight = $(".sidebar").height()
  if sidebarHeight < contentHeight
    $(".sidebar").height contentHeight
  else
    $(".sidebar").height sidebarHeight
$(window).load ->
  resizeSidebarBackground()

$(window).resize ->
  resizeSidebarBackground()

$('.content-wrapper').resize ->
  resizeSidebarBackground()