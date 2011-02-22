$(function(){
    $.getJSON(app_root+'/api/search.json?word='+page_name, function(res){
        if(res.error){
        }
        else{
            res.forEach(function(i){
                var box = $('<span>');
                var a = $('<a>').append(i.name).attr('href',app_root+'/'+i.name);
                box.append(a);
                box.click(function(){
                    location.href = app_root+'/'+i.name;
                });
                $('#related_pages').append(box);
            });
        }
    });
});