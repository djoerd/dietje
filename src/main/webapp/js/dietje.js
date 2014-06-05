/*!
 * Dietje v0.1 
 * Copyright 2014 Universiteit Twente
 * Licensed under http://dbappl.cs.utwente.nl/Legal/PfTijah-1.1.html
 */


function dietjeUrlParameters() {
  var params = new Object();
  params.course = "";
  params.nickname = "";
  params.assignment = "";
  var paramString = window.location.search.substring(1);
  var parts = paramString.split("&");
  for (var i=0; i < parts.length; i++) {
    var values = parts[i].split("=");
    if (values[0] == 'course') {
      params.course = values[1];
    }
    else if (values[0] == 'nickname') {
      params.nickname = values[1];
    }
    else if (values[0] == 'assignment') {
      params.assignment = values[1];
    }
  }
  return params;
}

function dietjeMenu(active) {
  var ca = ' class="active"';
  var c_active ='', s_active = '', a_active = '', l_active = '';

  if (active == 'courses') { c_active = ca; }
  else if (active == 'students') { s_active = ca; }
  else if (active == 'assignments') { a_active = ca; }
  else if (active == 'login') { l_active = ca; }

  var paramString = window.location.search.substring(1);
  if (paramString != '') { paramString = '?' + paramString; }

  var result = '<ul class="nav navbar-nav">\n';
  result += '<li' + c_active + '><a href="courses.html' + 
            paramString + '">Courses</a></li>';
  result += '<li' + s_active + '><a href="students.html' +  
            paramString + '">Students</a></li>';
  result += '<li' + a_active + '><a href="assignments.html' +  
            paramString + '">Assignments</a></li>';
  result += '<li' + l_active + '><a href="login.html' +
            paramString + '">Login</a></li>';
  result += '</ul>';

  document.getElementById('topmenu').innerHTML = result;
}
