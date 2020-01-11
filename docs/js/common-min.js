function debugMessage(c,b){var a="";a+="<h2>Houston, we have a problem</h2>";a+="<h3>Browser</h3><p>You need at least Chrome 1, Firefox 4, IE8, Safari 4 or Opera 10</p>";a+="<h3>Debug</h3><p>"+c+": "+b+"</p>";return a}function parameterMessage(c,b){var a="";a+="<h2>Hello, I'm Sorry...</h2>";a+="<p>Unrecognised "+c+" specified in the URL - "+b+"</p>";return a}function header(){var a="";if(getViewportWidth()<IPHONE_LANDSCAPE){a+="<p>Tip: Best viewed in landscape mode on mobile phones and some tablets.</p>"}return a}function footer(){var a="";return a}var COMMON_LANDSCAPE=1280;var COMMON_PORTRAIT=720;var IPAD_LANDSCAPE=1024;var IPAD_PORTRAIT=768;var GALAXY_S3_LANDSCAPE=640;var GALAXY_S3_PORTRAIT=360;var IPHONE_LANDSCAPE=480;var IPHONE_PORTRAIT=320;function getViewportWidth(){return document.documentElement.clientWidth}function getViewportHeight(){return document.documentElement.clientHeight}var eventIds=[];var personIds=[];var countryIds=[];var continentIds=[];var competitionIds=[];function getEventIds(){if(eventIds.length==0){for(var a=0;a<rankings.events.length;a++){eventIds.push(rankings.events[a].id)}}return eventIds}function getPersonIds(){if(personIds.length==0){for(var a=0;a<rankings.persons.length;a++){personIds.push(rankings.persons[a].id)}}return personIds}function getCountryIds(){if(countryIds.length==0){for(var a=0;a<rankings.countries.length;a++){countryIds.push(rankings.countries[a].id)}}return countryIds}function getContinentIds(){if(continentIds.length==0){for(var a=0;a<rankings.continents.length;a++){continentIds.push(rankings.continents[a].id)}}return continentIds}function getCompetitionIds(){if(competitionIds.length==0&&rankings.hasOwnProperty("competitions")){for(var a=0;a<rankings.competitions.length;a++){competitionIds.push(rankings.competitions[a].id)}}return competitionIds}function getResultTypes(){var b=[];for(var e=0;e<rankings.events.length;e++){var d=rankings.events[e];for(var c=0;c<d.rankings.length;c++){var a=d.rankings[c];if(b.indexOf(a.type)<0){b.push(a.type)}}}if(b.indexOf("average")>=0&&b.indexOf("single")>=0){b=["single","average"]}return b}function addEventHandler(d,b,c){var a="on"+b;if(b=="hashchange"&&!(a in d)){hashChangeFallback(d,c)}else{if(d.addEventListener){d.addEventListener(b,c,false)}else{if(d.attachEvent){d.attachEvent(a,c)}}}}function hashChangeFallback(b,a){b.onhashchange=a;(function(e){var c=e.location,d=c.href,f=c.hash;setInterval(function(){var h=c.href,g=c.hash;if(g!=f&&typeof e.onhashchange==="function"){e.onhashchange({type:"hashchange",oldURL:d,newURL:h});d=h;f=g}},100)})(window)}var lastHash="n/a";var lastWidth=getViewportWidth();function renderPage(e){try{var d=false;if(e!=lastHash){d=true}else{if(e=="random"){d=true}}var a=getViewportWidth();if(a!=lastWidth){d=true}if(d){var f=e.substring(1).split("-");if(f[0].length==0||getEventIds().indexOf(f[0])>=0){renderRankings(f,a)}else{if(f[0]=="random"||getPersonIds().indexOf(f[0])>=0){renderPerson(f,a)}else{var c=parameterMessage("event or person",f[0]);document.getElementById("container").innerHTML=c}}lastHash=e;lastWidth=a}}catch(b){var c=debugMessage("renderPage",b.message);document.getElementById("container").innerHTML=c}}function hashChangeHandler(){try{var c=window.location.hash;renderPage(c)}catch(b){var a=debugMessage("hashChangeHandler",b.message);document.getElementById("container").innerHTML=a}}function resizeHandler(){try{var c=lastHash;renderPage(c)}catch(b){var a=debugMessage("resizeHandler",b.message);document.getElementById("container").innerHTML=a}}function popStateHandler(d){try{if(d.state!=null){var c=d.state.hash;renderPage(c);setTimeout(function(){window.scrollTo(d.state.xOffset,d.state.yOffset)},1)}else{var c=window.location.hash;renderPage(c)}}catch(b){var a=debugMessage("popStateHandler",b.message);document.getElementById("container").innerHTML=a}}function polyfillIndexOf(){if(!Array.prototype.indexOf){Array.prototype.indexOf=function(c,d){var b;if(this==null){throw new TypeError('"this" is null or not defined')}var e=Object(this);var a=e.length>>>0;if(a===0){return -1}var f=d|0;if(f>=a){return -1}b=Math.max(f>=0?f:a-Math.abs(f),0);while(b<a){if(b in e&&e[b]===c){return b}b++}return -1}}}function loadHandler(){try{polyfillIndexOf();addEventHandler(window,"hashchange",hashChangeHandler);addEventHandler(window,"resize",resizeHandler);addEventHandler(window,"popstate",popStateHandler);hashChangeHandler()}catch(b){var a=debugMessage("loadHandler",b.message);document.getElementById("container").innerHTML=a}}function storeWindowOffset(){try{var c={hash:lastHash,xOffset:window.pageXOffset,yOffset:window.pageYOffset};var d=document.title;var a=window.location.href;history.replaceState(c,d,a)}catch(b){}}function switchView(){storeWindowOffset();var a=document.getElementById("eventId");var b=a.options[a.selectedIndex].value;var j=document.getElementById("resultType");var g=j.options[j.selectedIndex].value;var o=document.getElementById("ageCategory");var f=o.options[o.selectedIndex].value;var k=document.getElementById("continentId");var d=k.options[k.selectedIndex].value.toLowerCase();var m=document.getElementById("countryId");var n=m.options[m.selectedIndex].value.toLowerCase();var i="#";if(n!="xx"){i+=b+"-"+g+"-"+f+"-"+d+"-"+n}else{if(d!="xx"){i+=b+"-"+g+"-"+f+"-"+d}else{if(f>40){i+=b+"-"+g+"-"+f}else{if(g!=getResultTypes()[0]){i+=b+"-"+g}else{i+=b}}}}try{if(navigator.userAgent.indexOf("Chrome/5.0")>-1){throw"Chrome/5.0"}var h={hash:i,xOffset:window.pageXOffset,yOffset:window.pageYOffset};var l=rankings.events[eventIds.indexOf(b)]+" - "+selectElement.options[selectElement.selectedIndex].text;var c=i;history.pushState(h,l,c);renderPage(i)}catch(e){window.location.hash=i}}addEventHandler(window,"load",loadHandler);function renderPerson(e,c){var b="";var a=getPersonIds();if(e[0]=="random"){personId=a[Math.floor(Math.random()*a.length)]}else{personId=e[0]}if(a.indexOf(personId)>=0){var d=rankings.persons[a.indexOf(personId)];b+="<h2>"+d.name+"</h2>";document.title=d.name;b+=e;b+=header();b+=footer()}else{b+=parameterMessage("person",personId)}document.getElementById("container").innerHTML=b};function renderOptions(l,g,d,b,q,p){var u=getPersonIds();var t=getCountryIds();var h=getContinentIds();var o=navigator.userAgent.indexOf("iPhone")>=0?"dd16":"dd14";var s="";if(o=="dd16"&&p>=COMMON_PORTRAIT||o=="dd14"&&p>=GALAXY_S3_LANDSCAPE){s+='<div class="'+o+'"><p><table><tr><th>Event:</th><th>Result:</th><th>Age:</th><th>Continent:</th><th>Country:</th></tr><tr>'}else{if(p>=GALAXY_S3_PORTRAIT){s+='<div class="'+o+'"><p><table><tr><th>Event:</th><th>Result:</th><th>Age:</th></tr><tr>'}}var e=filterEventIds(g,d,b,q);if(p<GALAXY_S3_PORTRAIT){s+='<div class="'+o+'"><table><tr><th>Event:</th>'}s+='<td class="event"><select id="eventId" onChange="switchView()">';for(var c=0;c<e.length;c++){var a=rankings.events[getEventIds().indexOf(e[c])];s+='<option value="'+a.id+'"';if(a.id==l){s+=" selected"}s+=">"+a.name+"</option>"}s+="</select></td>";var v=filterResultTypes(l,d,b,q);if(p<GALAXY_S3_PORTRAIT){s+="</tr><tr><th>Result:</th>"}s+='<td class="result"><select id="resultType" onChange="switchView()">';for(var r=0;r<v.length;r++){s+='<option value="'+v[r]+'"';if(v[r]==g){s+=" selected"}s+=">"+v[r].charAt(0).toUpperCase()+v[r].slice(1)+"</option>"}s+="</select></td>";var j=filterAgeCategories(l,g,b,q);if(p<GALAXY_S3_PORTRAIT){s+="</tr><tr><th>Age:</th>"}s+='<td class="age"><select id="ageCategory" onChange="switchView()">';for(var r=0;r<j.length;r++){s+='<option value="'+j[r]+'"';if(j[r]==d){s+=" selected"}s+=">Over "+j[r]+"</option>"}s+="</select></td>";if(o=="dd16"&&p<COMMON_PORTRAIT&&p>=GALAXY_S3_PORTRAIT||o=="dd14"&&p<GALAXY_S3_LANDSCAPE&&p>=GALAXY_S3_PORTRAIT){s+='</tr></table></p></div><div class="'+o+'"><p><table><tr><th>Continent:</th><th>Country:</th></tr><tr>'}var m=filterContinents(l,g,d,q);if(p<GALAXY_S3_PORTRAIT){s+="</tr><tr><th>Continent:</th>"}s+='<td class="continent"><select id="continentId" onChange="switchView()">';s+='<option value="xx"';if(b=="xx"){s+=" selected"}s+=">All Continents</option>";for(var r=0;r<h.length;r++){if(m.indexOf(h[r])>=0){var f=rankings.continents[r];s+='<option value="'+rankings.continents[r].id+'"';if(rankings.continents[r].id==b){s+=" selected"}s+=">"+rankings.continents[r].name+"</option>"}}s+="</select></td>";var k=filterCountries(l,g,d,b);if(p<GALAXY_S3_PORTRAIT){s+="</tr><tr><th>Country:</th>"}s+='<td class="country"><select id="countryId" onChange="switchView()">';s+='<option value="xx"';if(q=="xx"){s+=" selected"}s+=">All Countries</option>";for(var r=0;r<t.length;r++){if(k.indexOf(t[r])>=0){var n=rankings.countries[r];s+='<option value="'+rankings.countries[r].id+'"';if(rankings.countries[r].id==q){s+=" selected"}s+=">"+rankings.countries[r].name+"</option>"}}s+="</select></td></tr></table></p></div>";return s}function filterEventIds(e,d,a,j){var b=[];for(var m=0;m<rankings.events.length;m++){var h=rankings.events[m];for(var i=0;i<rankings.events[m].rankings.length;i++){var c=rankings.events[m].rankings[i];if(c.type==e&&c.age==d){for(var l=0;l<c.ranks.length;l++){var g=c.ranks[l];var f=rankings.persons[personIds.indexOf(g.id)];var k=rankings.countries[countryIds.indexOf(f.country)];if((a=="XX"||k.continent==a)&&(j=="XX"||f.country==j)){b.push(h.id);break}}}if(b.indexOf(h.id)>=0){break}}}return b}function filterResultTypes(a,d,b,i){var j=[];var g=rankings.events[getEventIds().indexOf(a)];for(var h=0;h<g.rankings.length;h++){var c=g.rankings[h];if(c.age==d&&j.indexOf(c.type)<0){for(var l=0;l<c.ranks.length;l++){var f=c.ranks[l];var e=rankings.persons[personIds.indexOf(f.id)];var k=rankings.countries[countryIds.indexOf(e.country)];if((b=="XX"||k.continent==b)&&(i=="XX"||e.country==i)){j.push(c.type);break}}}}if(j.indexOf("average")>=0&&j.indexOf("single")>=0){j=["single","average"]}return j}function filterAgeCategories(a,d,b,i){var j=[];var g=rankings.events[getEventIds().indexOf(a)];for(var h=0;h<g.rankings.length;h++){var c=g.rankings[h];if(c.type==d&&j.indexOf(c.age)<0){for(var l=0;l<c.ranks.length;l++){var f=c.ranks[l];var e=rankings.persons[personIds.indexOf(f.id)];var k=rankings.countries[countryIds.indexOf(e.country)];if((b=="XX"||k.continent==b)&&(i=="XX"||e.country==i)){j.push(c.age);break}}}}return j}function filterContinents(a,d,c,i){var j=[];var g=rankings.events[getEventIds().indexOf(a)];for(var h=0;h<g.rankings.length;h++){var b=g.rankings[h];if(b.type==d&&b.age==c){for(var l=0;l<b.ranks.length;l++){var f=b.ranks[l];var e=rankings.persons[personIds.indexOf(f.id)];var k=rankings.countries[countryIds.indexOf(e.country)];if((i=="XX"||e.country==i)&&j.indexOf(k.continent)<0){j.push(k.continent)}}}}return j}function filterCountries(a,e,d,b){var k=[];var h=rankings.events[getEventIds().indexOf(a)];for(var i=0;i<h.rankings.length;i++){var c=h.rankings[i];if(c.type==e&&c.age==d){for(var l=0;l<c.ranks.length;l++){var g=c.ranks[l];var f=rankings.persons[personIds.indexOf(g.id)];var j=rankings.countries[countryIds.indexOf(f.country)];if((b=="XX"||j.continent==b)&&k.indexOf(j.id)<0){k.push(j.id)}}}}return k}function renderTable(n,k,e,d,u,s){var x="";var A=getPersonIds();var y=getCountryIds();var l=getContinentIds();var z=getCompetitionIds();var a=rankings.events[getEventIds().indexOf(n)];for(var g=0;g<a.rankings.length;g++){var f=a.rankings[g];if(f.type==k&&f.age==e){x+='<div class="rankings"><table>';x+="<tr>";x+='<th class="rank">Rank</th>';x+="<th>Name</th>";x+='<th class="result">Result</th>';if(s>=IPHONE_LANDSCAPE){x+='<th class="country">Citizen of</th>'}if(s>=IPAD_LANDSCAPE&&rankings.hasOwnProperty("competitions")){x+='<th class="competition">Competition</th>'}x+="</tr>";var b=0;var i=0;var j=0;var m=0;var t=0;var h=0;for(var r=0;r<f.ranks.length;r++){var o=f.ranks[r];var v=rankings.persons[A.indexOf(o.id)];var q=rankings.countries[y.indexOf(v.country)];i++;if(o.best!=b){j=o.rank/i}if((d=="XX"||q.continent==d)&&(u=="XX"||q.id==u)){m++;if(o.hasOwnProperty("highlight")){x+='<tr class="highlight">'}else{x+="<tr>"}if(o.best!=t){h=Math.max(h,m*j-m);if(d=="XX"&&u=="XX"){x+='<td class="rank">'+o.rank+"</td>"}else{if(h==0){x+='<td class="rank">'+m+"</td>"}else{if(h<0.5){x+='<td class="rank likely">('+m+")</td>"}else{x+='<td class="rank estimate">('+(m+h).toFixed(0)+")</td>"}}}}else{x+='<td class="rank"></td>'}var w='<a target="_blank" href="https://www.worldcubeassociation.org/persons/'+o.id+"?event="+n+'">'+v.name+"</a>";if(s>=IPHONE_LANDSCAPE){x+="<td>"+w+(o.hasOwnProperty("age")?", "+o.age+"+":"")+"</td>";x+='<td class="result">'+o.best+"</td>";x+='<td><i class="flag flag-'+q.id+'"></i>&nbsp;'+q.name+"</td>";if(s>=IPAD_LANDSCAPE&&rankings.hasOwnProperty("competitions")){var p=rankings.competitions[z.indexOf(o.competition)];var c=rankings.countries[y.indexOf(p.country)];x+='<td><i class="flag flag-'+c.id+'"></i>&nbsp;<a target="_blank" href="https://www.worldcubeassociation.org/competitions/'+p.webId+"/results/by_person#"+v.id+'">'+p.name+"</a></td>"}}else{x+="<td>"+w+'<br/><i class="flag flag-'+q.id+'"></i>&nbsp;'+q.name+(o.hasOwnProperty("age")?", "+o.age+"+":"")+"</td>";x+='<td class="result">'+o.best+"</td>"}x+="</tr>";t=o.best}b=o.best}x+="</table></div>";if(f.hasOwnProperty("estimate")){if(d=="XX"&&u=="XX"){if(m!=f.estimate){x+="<p>"+m+" of "+f.estimate+" seniors listed.</p>"}x+="<p>Overall completeness of rankings = "+(100*i/f.estimate).toFixed(1)+"%</p>"}else{x+="<p>NOTE: The total number of seniors for this region is unknown. Bracketed rankings are crude estimates based on missing seniors around the world.</p>"}}}}return x}function renderRankings(b,c){var f="";var e=getEventIds();var a=b[0].length>0?b[0]:e[0];var h=b.length>1&&b[1].length>0?b[1].toLowerCase():getResultTypes()[0];var g=b.length>2&&b[2].length>0?b[2]:"40";var d=b.length>3&&b[3].length>0?b[3].toUpperCase():"XX";var j=b.length>4&&b[4].length>0?b[4].toUpperCase():"XX";if(e.indexOf(a)>=0){var i=rankings.events[e.indexOf(a)];document.title=i.name+" - Over "+g+"s";f+=header();f+=renderOptions(a,h,g,d,j,c);f+=renderTable(a,h,g,d,j,c);f+=footer()}else{f+=parameterMessage("event",a)}document.getElementById("title").innerHTML=document.title;document.getElementById("refreshed").innerHTML=rankings.refreshed;document.getElementById("container").innerHTML=f};