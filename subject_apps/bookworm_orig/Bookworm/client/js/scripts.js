console.log('scripts.js loaded.');

$(document).ready(function() {

  $("#owl").owlCarousel({});

  $(".book").mouseenter(function(){
    $(this).find(".book-cover").animate({left: '0px'});
  }).mouseleave(function(){
    $(this).find(".book-cover").animate({left: '150px'});
  });

});
