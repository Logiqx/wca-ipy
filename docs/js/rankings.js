//
// Render options as drop-down lists
//
function renderOptions(eventId, resultType, ageCategory, continentId, countryId, width)
{
	var personIds = getPersonIds();
	var countryIds = getCountryIds();
	var continentIds = getContinentIds();
	var dropDownClass = navigator.userAgent.indexOf("iPhone") >= 0 ? "dd16" : "dd14";

	var out = "";

	if (dropDownClass == "dd16" && width >= COMMON_PORTRAIT ||
		dropDownClass == "dd14" && width >= GALAXY_S3_LANDSCAPE)
	{
		out += "<div class=\"" + dropDownClass + "\"><p><table><tr><th>Event:</th><th>Result:</th><th>Age:</th><th>Continent:</th><th>Country:</th></tr><tr>";
	}
	else if (width >= GALAXY_S3_PORTRAIT)
	{
		out += "<div class=\"" + dropDownClass + "\"><p><table><tr><th>Event:</th><th>Result:</th><th>Age:</th></tr><tr>";
	}
	
	// Create select element for available events
	var filteredEvents = filterEventIds(resultType, ageCategory, continentId, countryId);
	if (width < GALAXY_S3_PORTRAIT)
	{
		out += "<div class=\"" + dropDownClass + "\"><table><tr><th>Event:</th>";
	}
	out += "<td class=\"event\"><select id=\"eventId\" onChange=\"switchView()\">";
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
	var resultTypes = filterResultTypes(eventId, ageCategory, continentId, countryId);
	if (width < GALAXY_S3_PORTRAIT)
	{
		out += "</tr><tr><th>Result:</th>";
	}
	out += "<td class=\"result\"><select id=\"resultType\" onChange=\"switchView()\">";
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
	var ageCategories = filterAgeCategories(eventId, resultType, continentId, countryId);
	if (width < GALAXY_S3_PORTRAIT)
	{
		out += "</tr><tr><th>Age:</th>";
	}
	out += "<td class=\"age\"><select id=\"ageCategory\" onChange=\"switchView()\">";
	for (var i = 0; i < ageCategories.length; i++)
	{
		out += "<option value=\"" + ageCategories[i] + "\"";
		if (ageCategories[i] == ageCategory)
		{
			out += " selected";
		}
		out += ">Over " + ageCategories[i] + "</option>";
	}
	out += "</select></td>";

	if (dropDownClass == "dd16" && width < COMMON_PORTRAIT && width >= GALAXY_S3_PORTRAIT ||
		dropDownClass == "dd14" && width < GALAXY_S3_LANDSCAPE && width >= GALAXY_S3_PORTRAIT)
	{
		out += "</tr></table></p></div><div class=\"" + dropDownClass + "\"><p><table><tr><th>Continent:</th><th>Country:</th></tr><tr>";
	}

	// Create select element for available continents
	var filteredContinents = filterContinents(eventId, resultType, ageCategory, countryId);
	if (width < GALAXY_S3_PORTRAIT)
	{
		out += "</tr><tr><th>Continent:</th>";
	}
	out += "<td class=\"continent\"><select id=\"continentId\" onChange=\"switchView()\">";
	out += "<option value=\"xx\"";
	if (continentId == "xx")
	{
		out += " selected";
	}
	out += ">All Continents</option>";
	for (var i = 0; i < continentIds.length; i++)
	{
		if (filteredContinents.indexOf(continentIds[i]) >= 0)
		{
			var continentObj = rankings.continents[i];

			out += "<option value=\"" + rankings.continents[i].id + "\"";
			if (rankings.continents[i].id == continentId)
			{
				out += " selected";
			}
			out += ">" + rankings.continents[i].name + "</option>";
		}
	}
	out += "</select></td>";

	// Create select element for available countries
	var filteredCountries = filterCountries(eventId, resultType, ageCategory, continentId);
	if (width < GALAXY_S3_PORTRAIT)
	{
		out += "</tr><tr><th>Country:</th>";
	}
	out += "<td class=\"country\"><select id=\"countryId\" onChange=\"switchView()\">";
	out += "<option value=\"xx\"";
	if (countryId == "xx")
	{
		out += " selected";
	}
	out += ">All Countries</option>";
	for (var i = 0; i < countryIds.length; i++)
	{
		if (filteredCountries.indexOf(countryIds[i]) >= 0)
		{
			var countryObj = rankings.countries[i];

			out += "<option value=\"" + rankings.countries[i].id + "\"";
			if (rankings.countries[i].id == countryId)
			{
				out += " selected";
			}
			out += ">" + rankings.countries[i].name + "</option>";
		}
	}
	out += "</select></td></tr></table></p></div>";

	return out;
}

//
// List events related to result type and age category
//
function filterEventIds(resultType, ageCategory, continentId, countryId)
{
	var eventIds = [];

	for (var eventIdx = 0; eventIdx < rankings.events.length; eventIdx++)
	{
		var eventObj = rankings.events[eventIdx];
	
		for (var rankingIdx = 0; rankingIdx < rankings.events[eventIdx].rankings.length; rankingIdx++)
		{
			var rankingObj = rankings.events[eventIdx].rankings[rankingIdx];

			if (rankingObj.type == resultType && rankingObj.age == ageCategory)
			{
				for (var rankIdx = 0; rankIdx < rankingObj.ranks.length; rankIdx++)
				{
					var rankObj = rankingObj.ranks[rankIdx];
					var personObj = rankings.persons[personIds.indexOf(rankObj.id)]
					var countryObj = rankings.countries[countryIds.indexOf(personObj.country)]

					if ((continentId == "XX" || countryObj.continent == continentId) &&
						(countryId == "XX" || personObj.country == countryId))
					{
						eventIds.push(eventObj.id);
						break;
					}
				}
			}
			
			if (eventIds.indexOf(eventObj.id) >= 0)
			{
				break;
			}
		}
	}

	return eventIds;
}

//
// List result types related to event and age category
//
function filterResultTypes(eventId, ageCategory, continentId, countryId)
{
	var resultTypes = [];
	
	var eventObj = rankings.events[getEventIds().indexOf(eventId)];
	
	for (var rankingIdx = 0; rankingIdx < eventObj.rankings.length; rankingIdx++)
	{
		var rankingObj = eventObj.rankings[rankingIdx];
		
		if (rankingObj.age == ageCategory && resultTypes.indexOf(rankingObj.type) < 0)
		{
			for (var rankIdx = 0; rankIdx < rankingObj.ranks.length; rankIdx++)
			{
				var rankObj = rankingObj.ranks[rankIdx];
				var personObj = rankings.persons[personIds.indexOf(rankObj.id)]
				var countryObj = rankings.countries[countryIds.indexOf(personObj.country)]

				if ((continentId == "XX" || countryObj.continent == continentId) &&
					(countryId == "XX" || personObj.country == countryId))
				{
					resultTypes.push(rankingObj.type);
					break;
				}
			}
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
function filterAgeCategories(eventId, resultType, continentId, countryId)
{
	var ageCategories = [];
	
	var eventObj = rankings.events[getEventIds().indexOf(eventId)];
	
	for (var rankingIdx = 0; rankingIdx < eventObj.rankings.length; rankingIdx++)
	{
		var rankingObj = eventObj.rankings[rankingIdx];
		
		if (rankingObj.type == resultType && ageCategories.indexOf(rankingObj.age) < 0)
		{
			for (var rankIdx = 0; rankIdx < rankingObj.ranks.length; rankIdx++)
			{
				var rankObj = rankingObj.ranks[rankIdx];
				var personObj = rankings.persons[personIds.indexOf(rankObj.id)]
				var countryObj = rankings.countries[countryIds.indexOf(personObj.country)]

				if ((continentId == "XX" || countryObj.continent == continentId) &&
					(countryId == "XX" || personObj.country == countryId))
				{
					ageCategories.push(rankingObj.age);
					break;
				}
			}
		}
	}

	return ageCategories;
}

//
// List countries related to event, result type and age category
//
function filterContinents(eventId, resultType, ageCategory, countryId)
{
	var continents = [];

	var eventObj = rankings.events[getEventIds().indexOf(eventId)];

	for (var rankingIdx = 0; rankingIdx < eventObj.rankings.length; rankingIdx++)
	{
		var rankingObj = eventObj.rankings[rankingIdx];

		if (rankingObj.type == resultType && rankingObj.age == ageCategory)
		{
			for (var rankIdx = 0; rankIdx < rankingObj.ranks.length; rankIdx++)
			{
				var rankObj = rankingObj.ranks[rankIdx];
				var personObj = rankings.persons[personIds.indexOf(rankObj.id)]
				var countryObj = rankings.countries[countryIds.indexOf(personObj.country)]

				if ((countryId == "XX" || personObj.country == countryId) &&
					continents.indexOf(countryObj.continent) < 0)
				{
					continents.push(countryObj.continent);
				}
			}
		}
	}

	return continents;
}

//
// List countries related to event, result type and age category
//
function filterCountries(eventId, resultType, ageCategory, continentId)
{
	var countries = [];

	var eventObj = rankings.events[getEventIds().indexOf(eventId)];

	for (var rankingIdx = 0; rankingIdx < eventObj.rankings.length; rankingIdx++)
	{
		var rankingObj = eventObj.rankings[rankingIdx];

		if (rankingObj.type == resultType && rankingObj.age == ageCategory)
		{
			for (var rankIdx = 0; rankIdx < rankingObj.ranks.length; rankIdx++)
			{
				var rankObj = rankingObj.ranks[rankIdx];
				var personObj = rankings.persons[personIds.indexOf(rankObj.id)]
				var countryObj = rankings.countries[countryIds.indexOf(personObj.country)]

				if ((continentId == "XX" || countryObj.continent == continentId) &&
					countries.indexOf(countryObj.id) < 0)
				{
					countries.push(countryObj.id);
				}
			}
		}
	}

	return countries;
}

//
// Render results in a simple table
//
function renderTable(eventId, resultType, ageCategory, continentId, countryId, width)
{
	var out = "";

	var personIds = getPersonIds();
	var countryIds = getCountryIds();
	var continentIds = getContinentIds();
	var competitionIds = getCompetitionIds();

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
				out += '<th>Citizen of</th>';
			}
			if (width >= IPAD_LANDSCAPE && rankings.hasOwnProperty("competitions"))
			{
				out += '<th>Competition</th>';
			}
			out += '<th class=\"result\">Result</th>';
			out += '</tr>';
			
			var prevBest = 0;
			var count = 0;
			var ratio = 0;

			var filterCount = 0;
			var filterPrev = 0;
			var filterAdj = 0;

			for (var rankIdx = 0; rankIdx < rankingObj.ranks.length; rankIdx++)
			{
				var rankObj = rankingObj.ranks[rankIdx];
				var personObj = rankings.persons[personIds.indexOf(rankObj.id)];
				var countryObj = rankings.countries[countryIds.indexOf(personObj.country)];

				count++;
				if (rankObj.best != prevBest)
				{
					ratio = rankObj.rank / count;
				}

				if ((continentId == "XX" || countryObj.continent == continentId) &&
					(countryId == "XX" || countryObj.id == countryId))
				{
					filterCount++;

					if (rankObj.hasOwnProperty("highlight"))
					{
						out += '<tr class=\"highlight\">';
					}
					else
					{
						out += '<tr>';
					}
					if (rankObj.best != filterPrev)
					{
						filterAdj = Math.max(filterAdj, (filterCount * ratio).toFixed(0) - filterCount);
						if (filterAdj == 0 || continentId == "XX" && countryId == "XX")
						{
							out += '<td class=\"rank\">' + (filterCount + filterAdj) + '</td>';
						}
						else
						{
							out += '<td class=\"rank\">(' + (filterCount + filterAdj) + ')</td>';
						}
					}
					else
					{
						out += '<td class=\"rank\"></td>';
					}

					var href = '<a href=\"https://www.worldcubeassociation.org/persons/' + rankObj.id + '?event=' + eventId + '\">' + personObj.name + '</a>';
					if (width >= IPHONE_LANDSCAPE)
					{
						out += '<td>' + href + (rankObj.hasOwnProperty("age") ? ', ' + rankObj.age + '+' : '') + '</td>';
						out += '<td><i class="flag flag-' + countryObj.id + '"></i>&nbsp;' + countryObj.name + '</td>';

						if (width >= IPAD_LANDSCAPE && rankings.hasOwnProperty("competitions"))
						{
							var competitionObj = rankings.competitions[competitionIds.indexOf(rankObj.competition)];
							var compCountryObj = rankings.countries[countryIds.indexOf(competitionObj.country)];

							out += '<td><i class="flag flag-' + compCountryObj.id + '"></i>&nbsp;' +
								'<a href="https://www.worldcubeassociation.org/competitions/' + competitionObj.webId + '/results/by_person#' + personObj.id + '">' +
								competitionObj.name + '</a></td>';
						}
					}
					else
					{
						out += '<td>' + href + '<br/><i class="flag flag-' + countryObj.id + '"></i>&nbsp;' + countryObj.name +
							(rankObj.hasOwnProperty("age") ? ', ' + rankObj.age + '+' : '') + '</td>';
					}
					out += '<td class=\"result\">' + rankObj.best + '</td>';
					out += '</tr>';

					filterPrev = rankObj.best;
				}

				prevBest = rankObj.best;
			}

			out += '</table></div>';

			if (rankingObj.hasOwnProperty("estimate"))
			{
				if (continentId == "XX" && countryId == "XX")
				{
					out += '<p>Total number of seniors = ' + rankingObj.estimate + '</p>';
					out += '<p>Overall completeness of rankings = ' + (100 * count / rankingObj.estimate).toFixed(1) + '%</p>';
				}
				else
				{
					out += '<p>NOTE: Bracketed rankings have been adjusted due to missing seniors worldwide.</p>';
				}
			}
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
	var resultType = hashParts.length > 1 && hashParts[1].length > 0 ? hashParts[1].toLowerCase() : getResultTypes()[0];
	var ageCategory = hashParts.length > 2 && hashParts[2].length > 0 ? hashParts[2] : "40";
	var continentId = hashParts.length > 3 && hashParts[3].length > 0 ? hashParts[3].toUpperCase() : "XX";
	var countryId = hashParts.length > 4 && hashParts[4].length > 0 ? hashParts[4].toUpperCase() : "XX";
	
	// Check if the event exists
	if (eventIds.indexOf(eventId) >= 0)
	{
		var eventObj = rankings.events[eventIds.indexOf(eventId)];

		document.title = eventObj.name + " - Over " + ageCategory + "s";

		out += header();
		out += renderOptions(eventId, resultType, ageCategory, continentId, countryId, width);
		out += renderTable(eventId, resultType, ageCategory, continentId, countryId, width);
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
