$(function(){
    $.getJSON(app_root+'/api/related_pages.json?page='+page_name, function(res){
        if(res.error){
        }
        else{
            res.forEach(function(i){
                var box = $('<span>');
                var a = $('<a>').attr('href',app_root+'/'+i.name);
                if(i.img){
                    a.append($('<img>').attr('src',i.img));
                }
                else{
                    a.append(i.name);
                }
                box.append(a);
                box.click(function(){
                    location.href = app_root+'/'+i.name;
                });
                $('#related_pages').append(box);
            });
        }
    });
});