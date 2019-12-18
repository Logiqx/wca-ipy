function debugMessage(c,b){var a="";a+="<h2>Houston, we have a problem</h2>";a+="<h3>Browser</h3><p>You need at least Chrome 1, Firefox 4, IE8, Safari 4 or Opera 10</p>";a+="<h3>Debug</h3><p>"+c+": "+b+"</p>";return a}function parameterMessage(c,b){var a="";a+="<h2>Hello, I'm Sorry...</h2>";a+="<p>Unrecognised "+c+" specified in the URL - "+b+"</p>";return a}function header(){var a="";if(getViewportWidth()<IPHONE_LANDSCAPE){a+="<p>Tip: Best viewed in landscape mode on mobile phones and some tablets.</p>"}return a}function footer(){var a="";return a}var COMMON_LANDSCAPE=1080;var COMMON_PORTRAIT=720;var IPAD_LANDSCAPE=1024;var IPAD_PORTRAIT=768;var GALAXY_S3_LANDSCAPE=640;var GALAXY_S3_PORTRAIT=360;var IPHONE_LANDSCAPE=480;var IPHONE_PORTRAIT=320;function getViewportWidth(){return document.documentElement.clientWidth}function getViewportHeight(){return document.documentElement.clientHeight}var eventIds=[];var personIds=[];var countryIds=[];var continentIds=[];function getEventIds(){if(eventIds.length==0){for(var a=0;a<rankings.events.length;a++){eventIds.push(rankings.events[a].id)}}return eventIds}function getPersonIds(){if(personIds.length==0){for(var a=0;a<rankings.persons.length;a++){personIds.push(rankings.persons[a].id)}}return personIds}function getCountryIds(){if(countryIds.length==0){for(var a=0;a<rankings.countries.length;a++){countryIds.push(rankings.countries[a].id)}}return countryIds}function getContinentIds(){if(continentIds.length==0){for(var a=0;a<rankings.continents.length;a++){continentIds.push(rankings.continents[a].id)}}return continentIds}function getResultTypes(){var b=[];for(var e=0;e<rankings.events.length;e++){var d=rankings.events[e];for(var c=0;c<d.rankings.length;c++){var a=d.rankings[c];if(b.indexOf(a.type)<0){b.push(a.type)}}}if(b.indexOf("average")>=0&&b.indexOf("single")>=0){b=["single","average"]}return b}function addEventHandler(d,b,c){var a="on"+b;if(b=="hashchange"&&!(a in d)){hashChangeFallback(d,c)}else{if(d.addEventListener){d.addEventListener(b,c,false)}else{if(d.attachEvent){d.attachEvent(a,c)}}}}function hashChangeFallback(b,a){b.onhashchange=a;(function(e){var c=e.location,d=c.href,f=c.hash;setInterval(function(){var h=c.href,g=c.hash;if(g!=f&&typeof e.onhashchange==="function"){e.onhashchange({type:"hashchange",oldURL:d,newURL:h});d=h;f=g}},100)})(window)}var lastHash="n/a";var lastWidth=getViewportWidth();function renderPage(e){try{var d=false;if(e!=lastHash){d=true}else{if(e=="random"){d=true}}var a=getViewportWidth();if(a!=lastWidth){d=true}if(d){var f=e.substring(1).split("-");if(f[0].length==0||getEventIds().indexOf(f[0])>=0){renderRankings(f,a)}else{if(f[0]=="random"||getPersonIds().indexOf(f[0])>=0){renderPerson(f,a)}else{var c=parameterMessage("event or person",f[0]);document.getElementById("container").innerHTML=c}}lastHash=e;lastWidth=a}}catch(b){var c=debugMessage("renderPage",b.message);document.getElementById("container").innerHTML=c}}function hashChangeHandler(){try{var c=window.location.hash;renderPage(c)}catch(b){var a=debugMessage("hashChangeHandler",b.message);document.getElementById("container").innerHTML=a}}function resizeHandler(){try{var c=lastHash;renderPage(c)}catch(b){var a=debugMessage("resizeHandler",b.message);document.getElementById("container").innerHTML=a}}function popStateHandler(d){try{if(d.state!=null){var c=d.state.hash;renderPage(c);setTimeout(function(){window.scrollTo(d.state.xOffset,d.state.yOffset)},1)}else{var c=window.location.hash;renderPage(c)}}catch(b){var a=debugMessage("popStateHandler",b.message);document.getElementById("container").innerHTML=a}}function polyfillIndexOf(){if(!Array.prototype.indexOf){Array.prototype.indexOf=function(c,d){var b;if(this==null){throw new TypeError('"this" is null or not defined')}var e=Object(this);var a=e.length>>>0;if(a===0){return -1}var f=d|0;if(f>=a){return -1}b=Math.max(f>=0?f:a-Math.abs(f),0);while(b<a){if(b in e&&e[b]===c){return b}b++}return -1}}}function loadHandler(){try{polyfillIndexOf();addEventHandler(window,"hashchange",hashChangeHandler);addEventHandler(window,"resize",resizeHandler);addEventHandler(window,"popstate",popStateHandler);hashChangeHandler()}catch(b){var a=debugMessage("loadHandler",b.message);document.getElementById("container").innerHTML=a}}function storeWindowOffset(){try{var c={hash:lastHash,xOffset:window.pageXOffset,yOffset:window.pageYOffset};var d=document.title;var a=window.location.href;history.replaceState(c,d,a)}catch(b){}}function switchView(){storeWindowOffset();var a=document.getElementById("eventId");var b=a.options[a.selectedIndex].value;var j=document.getElementById("resultType");var g=j.options[j.selectedIndex].value;var o=document.getElementById("ageCategory");var f=o.options[o.selectedIndex].value;var k=document.getElementById("continentId");var d=k.options[k.selectedIndex].value.toLowerCase();var m=document.getElementById("countryId");var n=m.options[m.selectedIndex].value.toLowerCase();var i="#";if(n!="xx"){i+=b+"-"+g+"-"+f+"-"+d+"-"+n}else{if(d!="xx"){i+=b+"-"+g+"-"+f+"-"+d}else{if(f>40){i+=b+"-"+g+"-"+f}else{if(g!=getResultTypes()[0]){i+=b+"-"+g}else{i+=b}}}}try{if(navigator.userAgent.indexOf("Chrome/5.0")>-1){throw"Chrome/5.0"}var h={hash:i,xOffset:window.pageXOffset,yOffset:window.pageYOffset};var l=rankings.events[eventIds.indexOf(b)]+" - "+selectElement.options[selectElement.selectedIndex].text;var c=i;history.pushState(h,l,c);renderPage(i)}catch(e){window.location.hash=i}}addEventHandler(window,"load",loadHandler);function renderPerson(e,c){var b="";var a=getPersonIds();if(e[0]=="random"){personId=a[Math.floor(Math.random()*a.length)]}else{personId=e[0]}if(a.indexOf(personId)>=0){var d=rankings.persons[a.indexOf(personId)];b+="<h2>"+d.name+"</h2>";document.title=d.name;b+=e;b+=header();b+=footer()}else{b+=parameterMessage("person",personId)}document.getElementById("container").innerHTML=b};function renderOptions(l,g,d,b,p,o){var t=getPersonIds();var s=getCountryIds();var h=getContinentIds();var r="";if(o>=COMMON_PORTRAIT){r+='<div class="dropdowns"><p><table><tr><th>Event:</th><th>Result:</th><th>Age:</th><th>Continent:</th><th>Country:</th></tr><tr>'}else{if(o>=GALAXY_S3_PORTRAIT){r+='<div class="dropdowns"><p><table><tr><th>Event:</th><th>Result:</th><th>Age:</th></tr><tr>'}}var e=filterEventIds(g,d,b,p);if(o<GALAXY_S3_PORTRAIT){r+='<div class="dropdowns"><table><tr><th>Event:</th>'}r+='<td><select id="eventId" onChange="switchView()">';for(var c=0;c<e.length;c++){var a=rankings.events[getEventIds().indexOf(e[c])];r+='<option value="'+a.id+'"';if(a.id==l){r+=" selected"}r+=">"+a.name+"</option>"}r+="</select></td>";var u=filterResultTypes(l,d,b,p);if(o<GALAXY_S3_PORTRAIT){r+="</tr><tr><th>Result:</th>"}r+='<td><select id="resultType" onChange="switchView()">';for(var q=0;q<u.length;q++){r+='<option value="'+u[q]+'"';if(u[q]==g){r+=" selected"}r+=">"+u[q].charAt(0).toUpperCase()+u[q].slice(1)+"</option>"}r+="</select></td>";var j=filterAgeCategories(l,g,b,p);if(o<GALAXY_S3_PORTRAIT){r+="</tr><tr><th>Age:</th>"}r+='<td><select id="ageCategory" onChange="switchView()">';for(var q=0;q<j.length;q++){r+='<option value="'+j[q]+'"';if(j[q]==d){r+=" selected"}r+=">Over "+j[q]+"</option>"}r+="</select></td>";if(o<COMMON_PORTRAIT&&o>=GALAXY_S3_PORTRAIT){r+='</tr></table></p></div><div class="dropdowns"><p><table><tr><th>Continent:</th><th>Country:</th></tr><tr>'}var m=filterContinents(l,g,d,p);if(o<GALAXY_S3_PORTRAIT){r+="</tr><tr><th>Continent:</th>"}r+='<td><select id="continentId" onChange="switchView()">';r+='<option value="xx"';if(b=="xx"){r+=" selected"}r+=">All Continents</option>";for(var q=0;q<h.length;q++){if(m.indexOf(h[q])>=0){var f=rankings.continents[q];r+='<option value="'+rankings.continents[q].id+'"';if(rankings.continents[q].id==b){r+=" selected"}r+=">"+rankings.continents[q].name+"</option>"}}r+="</select></td>";var k=filterCountries(l,g,d,b);if(o<GALAXY_S3_PORTRAIT){r+="</tr><tr><th>Country:</th>"}r+='<td><select id="countryId" onChange="switchView()">';r+='<option value="xx"';if(p=="xx"){r+=" selected"}r+=">All Countries</option>";for(var q=0;q<s.length;q++){if(k.indexOf(s[q])>=0){var n=rankings.countries[q];r+='<option value="'+rankings.countries[q].id+'"';if(rankings.countries[q].id==p){r+=" selected"}r+=">"+rankings.countries[q].name+"</option>"}}r+="</select></td></tr></table></p></div>";return r}function filterEventIds(e,d,a,j){var b=[];for(var m=0;m<rankings.events.length;m++){var h=rankings.events[m];for(var i=0;i<rankings.events[m].rankings.length;i++){var c=rankings.events[m].rankings[i];if(c.type==e&&c.age==d){for(var l=0;l<c.ranks.length;l++){var g=c.ranks[l];var f=rankings.persons[personIds.indexOf(g.id)];var k=rankings.countries[countryIds.indexOf(f.country)];if((a=="XX"||k.continent==a)&&(j=="XX"||f.country==j)){b.push(h.id);break}}}if(b.indexOf(h.id)>=0){break}}}return b}function filterResultTypes(a,d,b,i){var j=[];var g=rankings.events[getEventIds().indexOf(a)];for(var h=0;h<g.rankings.length;h++){var c=g.rankings[h];if(c.age==d&&j.indexOf(c.type)<0){for(var l=0;l<c.ranks.length;l++){var f=c.ranks[l];var e=rankings.persons[personIds.indexOf(f.id)];var k=rankings.countries[countryIds.indexOf(e.country)];if((b=="XX"||k.continent==b)&&(i=="XX"||e.country==i)){j.push(c.type);break}}}}if(j.indexOf("average")>=0&&j.indexOf("single")>=0){j=["single","average"]}return j}function filterAgeCategories(a,d,b,i){var j=[];var g=rankings.events[getEventIds().indexOf(a)];for(var h=0;h<g.rankings.length;h++){var c=g.rankings[h];if(c.type==d&&j.indexOf(c.age)<0){for(var l=0;l<c.ranks.length;l++){var f=c.ranks[l];var e=rankings.persons[personIds.indexOf(f.id)];var k=rankings.countries[countryIds.indexOf(e.country)];if((b=="XX"||k.continent==b)&&(i=="XX"||e.country==i)){j.push(c.age);break}}}}return j}function filterContinents(a,d,c,i){var j=[];var g=rankings.events[getEventIds().indexOf(a)];for(var h=0;h<g.rankings.length;h++){var b=g.rankings[h];if(b.type==d&&b.age==c){for(var l=0;l<b.ranks.length;l++){var f=b.ranks[l];var e=rankings.persons[personIds.indexOf(f.id)];var k=rankings.countries[countryIds.indexOf(e.country)];if((i=="XX"||e.country==i)&&j.indexOf(k.continent)<0){j.push(k.continent)}}}}return j}function filterCountries(a,e,d,b){var k=[];var h=rankings.events[getEventIds().indexOf(a)];for(var i=0;i<h.rankings.length;i++){var c=h.rankings[i];if(c.type==e&&c.age==d){for(var l=0;l<c.ranks.length;l++){var g=c.ranks[l];var f=rankings.persons[personIds.indexOf(g.id)];var j=rankings.countries[countryIds.indexOf(f.country)];if((b=="XX"||j.continent==b)&&k.indexOf(j.id)<0){k.push(j.id)}}}}return k}function renderTable(m,j,d,c,s,q){var v="";var x=getPersonIds();var w=getCountryIds();var k=getContinentIds();var a=rankings.events[getEventIds().indexOf(m)];for(var f=0;f<a.rankings.length;f++){var e=a.rankings[f];if(e.type==j&&e.age==d){v+='<div class="rankings"><table>';v+="<tr>";v+='<th class="rank">Rank</th>';v+="<th>Person</th>";if(q>=IPHONE_LANDSCAPE){v+="<th>Country</th>"}v+="<th>Result</th>";v+="</tr>";var b=0;var h=0;var i=0;var l=0;var r=0;var g=0;for(var p=0;p<e.ranks.length;p++){var n=e.ranks[p];var t=rankings.persons[x.indexOf(n.id)];var o=rankings.countries[w.indexOf(t.country)];h++;if(n.best!=b){i=n.rank/h}if((c=="XX"||o.continent==c)&&(s=="XX"||o.id==s)){l++;v+="<tr>";if(n.best!=r){g=Math.max(g,(l*i).toFixed(0)-l);v+='<td class="rank">'+(l+g)+"</td>"}else{v+='<td class="rank"></td>'}var u='<a href="https://www.worldcubeassociation.org/persons/'+n.id+"?event="+m+'">'+t.name+"</a>";if(q>=IPHONE_LANDSCAPE){v+="<td>"+u+(n.hasOwnProperty("age")?", "+n.age+"+":"")+"</td>";v+="<td>"+o.name+"</td>"}else{v+="<td>"+u+", "+o.name+(n.hasOwnProperty("age")?", "+n.age+"+":"")+"</td>"}v+='<td class="result">'+n.best+"</td>";v+="</tr>";r=n.best}b=n.best}v+="</table></div>";if(e.hasOwnProperty("estimate")){if(c=="XX"&&s=="XX"){v+="<p>Estimated number of seniors &#8776; "+e.estimate+"</p>";v+="<p>Estimated completeness of rankings &#8776; "+(100*h/e.estimate).toFixed(1)+"%</p>"}else{if(i>1){v+="<p>NOTE: The ranks have been calculated using any existing knowledge of missing seniors (worldwide).</p>"}}}}}return v}function renderRankings(b,c){var f="";var e=getEventIds();var a=b[0].length>0?b[0]:e[0];var h=b.length>1&&b[1].length>0?b[1].toLowerCase():getResultTypes()[0];var g=b.length>2&&b[2].length>0?b[2]:"40";var d=b.length>3&&b[3].length>0?b[3].toUpperCase():"XX";var j=b.length>4&&b[4].length>0?b[4].toUpperCase():"XX";if(e.indexOf(a)>=0){var i=rankings.events[e.indexOf(a)];document.title=i.name+" - Over "+g+"s";f+=header();f+=renderOptions(a,h,g,d,j,c);f+=renderTable(a,h,g,d,j,c);f+=footer()}else{f+=parameterMessage("event",a)}document.getElementById("title").innerHTML=document.title;document.getElementById("refreshed").innerHTML=rankings.refreshed;document.getElementById("container").innerHTML=f};