$(document).ready(function () {
  $("#projectInfo").hide();
  });
  
  $("#projectToggle a").click(function () {
  $("#projectInfo").slideToggle();
  });
  
  $("#projectToggle a").click(function () {
  $("#projectToggle span").toggleClass("material-icon-add material-icon-remove");
  });