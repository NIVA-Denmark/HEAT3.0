script <- "$('#tblOverall tbody tr td:last-child').each(function() {
var cellValue = $(this).text().trim();
if (cellValue == 'Bad') {
$(this).css('background-color', 'rgb(255,43,0)');
}
else if (cellValue == 'Poor') {
$(this).css('background-color', 'rgb(255,128,102)');
}
else if (cellValue == 'Moderate') {
$(this).css('background-color', 'rgb(255,213,204)');
}
else if (cellValue == 'Good') {
$(this).css('background-color', 'rgb(153,255,102)');
}
else if (cellValue == 'High') {
$(this).css('background-color', 'rgb(51,170,0)');
}
});
$('#tblCriteria tbody tr td:last-child').each(function() {
var cellValue = $(this).text().trim();
if (cellValue == 'Bad') {
$(this).css('background-color', 'rgb(255,43,0)');
}
else if (cellValue == 'Poor') {
$(this).css('background-color', 'rgb(255,128,102)');
}
else if (cellValue == 'Moderate') {
$(this).css('background-color', 'rgb(255,213,204)');
}
else if (cellValue == 'Good') {
$(this).css('background-color', 'rgb(153,255,102)');
}
else if (cellValue == 'High') {
$(this).css('background-color', 'rgb(51,170,0)');
}
});"

# 
# 51,170,0
# 153,255,102
# 255,213,204
# 255,128,102
# 255,43,0