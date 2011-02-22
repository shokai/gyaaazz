$(function(){
    $.getJSON(app_root+'/api/search.json?word='+page_name, function(res){
        console.log(res);
        if(res.error){
            
        }
        else{
            res.forEach(function(i){
                var box = $('<div>');
                var a = $('<a>').append(i.name).attr('href',app_root+'/'+i.name);
                box.append(a);
                $('#related_pages').append(box);
            });
        }
    });
});