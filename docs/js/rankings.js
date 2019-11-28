//
// Render options as drop-down lists
//
function renderOptions(eventId, resultType, ageCategory, width)
{
	var out = "";

	if (width >= GALAXY_S3_PORTRAIT)
	{
		out += "<div class=\"dropdowns\"><p><table><tr><th>Event:</th><th>Result:</th><th>Age:</th></tr><tr>";
	}
	
	// Create select element for available events
	var filteredEvents = filterEventIds(resultType, ageCategory);
	if (width < GALAXY_S3_PORTRAIT)
	{
		out += "<div class=\"dropdowns\"><table><tr><th>Event:</th>";
	}
	out += "<td><select id=\"eventId\" onChange=\"switchView()\">";
	for (var eventIdx = 0; eventIdx < filteredEvents.length; eventIdx++)
	{
		var eventObj = rankings.events[getEventIds().indexOf(filteredEvents[eventIdx])];
		out += "<option value=\"" + eventObj.id + "\"";
		if (eventObj.id == eventId)
		{
			out += " selected";
		}
		out += ">" + eventObj.name + "</option>";
	}
	out += "</select></td>";
	
	// Create select element for available result types
	var resultTypes = filterResultTypes(eventId, ageCategory);
	if (width < GALAXY_S3_PORTRAIT)
	{
		out += "</tr><tr><th>Result:</th>";
	}
	out += "<td><select id=\"resultType\" onChange=\"switchView()\">";
	for (var i = 0; i < resultTypes.length; i++)
	{
		out += "<option value=\"" + resultTypes[i] + "\"";
		if (resultTypes[i] == resultType)
		{
			out += " selected";
		}
		out += ">" + resultTypes[i].charAt(0).toUpperCase() + resultTypes[i].slice(1) + "</option>";
	}
	out += "</select></td>";

	// Create select element for available age categories
	var ageCategories = filterAgeCategories(eventId, resultType);
	if (width < GALAXY_S3_PORTRAIT)
	{
		out += "</tr><tr><th>Age:</th>";
	}
	out += "<td><select id=\"ageCategory\" onChange=\"switchView()\">";
	for (var i = 0; i < ageCategories.length; i++)
	{
		out += "<option value=\"" + ageCategories[i] + "\"";
		if (ageCategories[i] == ageCategory)
		{
			out += " selected";
		}
		out += ">Over " + ageCategories[i] + "</option>";
	}
	out += "</select></td></tr></table></p></div>";

	return out;
}

//
// List events related to result type and age category
//
function filterEventIds(resultType, ageCategory)
{
	var eventIds = [];

	for (var eventIdx = 0; eventIdx < rankings.events.length; eventIdx++)
	{
		var eventObj = rankings.events[eventIdx];
	
		for (var rankingIdx = 0; rankingIdx < rankings.events[eventIdx].rankings.length; rankingIdx++)
		{
			var rankingObj = rankings.events[eventIdx].rankings[rankingIdx];
			
			if (rankingObj.type == resultType && rankingObj.age == ageCategory && eventIds.indexOf(eventObj.id) < 0)
			{
				eventIds.push(eventObj.id)
			}
		}
	}

	return eventIds;
}

//
// List result types related to event and age category
//
function filterResultTypes(eventId, ageCategory)
{
	var resultTypes = [];
	
	var eventObj = rankings.events[getEventIds().indexOf(eventId)];
	
	for (var rankingIdx = 0; rankingIdx < eventObj.rankings.length; rankingIdx++)
	{
		var rankingObj = eventObj.rankings[rankingIdx];
		
		if (rankingObj.age == ageCategory && resultTypes.indexOf(rankingObj.type) < 0)
		{
			resultTypes.push(rankingObj.type)
		}
	}

	if (resultTypes.indexOf("average") >= 0 && resultTypes.indexOf("single") >= 0)
	{
		resultTypes = ["single", "average"];
	}

	return resultTypes;
}

//
// List age categories related to event and result type
//
function filterAgeCategories(eventId, resultType)
{
	var ageCategories = [];
	
	var eventObj = rankings.events[getEventIds().indexOf(eventId)];
	
	for (var rankingIdx = 0; rankingIdx < eventObj.rankings.length; rankingIdx++)
	{
		var rankingObj = eventObj.rankings[rankingIdx];
		
		if (rankingObj.type == resultType && ageCategories.indexOf(rankingObj.age) < 0)
		{
			ageCategories.push(rankingObj.age)
		}
	}

	return ageCategories;
}

//
// List age categories related to event and result type
//
function renderTable(eventId, resultType, ageCategory, width)
{
	var out = "";

	var personIds = getPersonIds();
	var countryIds = getCountryIds();

	var eventObj = rankings.events[getEventIds().indexOf(eventId)];
	
	for (var rankingIdx = 0; rankingIdx < eventObj.rankings.length; rankingIdx++)
	{
		var rankingObj = eventObj.rankings[rankingIdx];
		
		if (rankingObj.type == resultType && rankingObj.age == ageCategory)
		{
			out += '<div class=\"rankings\"><table>';
			out += '<tr>';
			out += '<th class=\"rank\">Rank</th>';
			out += '<th>Person</th>';
			if (width >= IPHONE_LANDSCAPE)
			{
				out += '<th>Country</th>';
			}
			out += '<th>Result</th>';
			out += '</tr>';
			
			var prevRank = 0;

			for (var rankIdx = 0; rankIdx < rankingObj.ranks.length; rankIdx++)
			{
				var rankObj = rankingObj.ranks[rankIdx];
				var personObj = rankings.persons[personIds.indexOf(rankObj.id)]
				var countryObj = rankings.countries[countryIds.indexOf(personObj.country)]

				out += '<tr>';
				out += '<td class=\"rank\">' + (rankObj.rank > prevRank ? rankObj.rank : '') + '</td>';
				var href = '<a href=\"https://www.worldcubeassociation.org/persons/' + rankObj.id + '?event=' + eventId + '\">' + personObj.name + '</a>';
				if (width >= IPHONE_LANDSCAPE)
				{
					out += '<td>' + href + (rankObj.hasOwnProperty("age") ? ', ' + rankObj.age + '+' : '') + '</td>';
					out += '<td>' + countryObj.name + '</td>';
				}
				else
				{
					out += '<td>' + href + ', ' + countryObj.name + (rankObj.hasOwnProperty("age") ? ', ' + rankObj.age + '+' : '') + '</td>';
				}
				out += '<td class=\"result\">' + rankObj.best + '</td>';
				out += '</tr>';

				prevRank = rankObj.rank;
			}

			out += '</table></div>';
		}
	}
	
	return out;
}

//
// Render the selected view
//
function renderRankings(hashParts, width)
{
	// Initialisation
	var out = "";
	
	// Array is used instead of Map() which doesn't work on my iPad
	var eventIds = getEventIds();
	
	// Determine the event
	var eventId = hashParts[0].length > 0 ? hashParts[0] : eventIds[0];
	var resultType = hashParts.length > 1 && hashParts[1].length > 0 ? hashParts[1] : getResultTypes()[0];
	var ageCategory = hashParts.length > 2 && hashParts[2].length > 0 ? hashParts[2] : "40";
	
	// Check if the event exists
	if (eventIds.indexOf(eventId) >= 0)
	{
		var eventObj = rankings.events[eventIds.indexOf(eventId)];

		document.title = eventObj.name + " - Over " + ageCategory + "s";

		out += header();
		out += renderOptions(eventId, resultType, ageCategory, width);
		out += renderTable(eventId, resultType, ageCategory, width);
		out += footer();	
	}
	else
	{
		out += parameterMessage('event', eventId); 
	}

	// Update the HTML
	document.getElementById("title").innerHTML = document.title;
	document.getElementById("refreshed").innerHTML = rankings.refreshed;
	document.getElementById("container").innerHTML = out;
}
