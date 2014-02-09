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
}`

