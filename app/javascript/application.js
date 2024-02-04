//= require jquery/dist/jquery.min.js
//= require datatables/media/js/jquery.dataTables.min.js
//= require apexcharts
//= require select2
//= require cocoon

$(document).ready(function() {
  $("select.select2").select2({
    language: "pt-BR",
    placeholder: " ",
    width: '100%',
    allowClear: true      
  });
});