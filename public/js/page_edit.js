$(function(){
    $('#save').click(function(){
        $.post(app_root+'/'+page_name+'.json',
               {lines : $('textarea#edit').val().split("\n")},
               function(res){
                   if(res.error) alert(res.message);
                   else location.href = app_root+'/'+page_name;
               }, 'json');
    });
});