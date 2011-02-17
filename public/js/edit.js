var lines;

$(function(){
   load_page(); 
});

var load_page = function(){
    $.getJSON(location.href+'.json', function(res){
        lines = res.body.split(/[\r\n]/);
        display();
    });
};

var display = function(){
    for(var i = 0; i < lines.length; i++){
        var line = $('<li>').append(lines[i]).attr('id','line_'+i);
        line.click(function(){
            
        });
        $('ul#edit').prepend(line);
    }
};