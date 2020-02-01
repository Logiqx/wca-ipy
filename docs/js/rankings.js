//
// Render options as drop-down lists
//
function renderOptions(eventId, resultType, ageCategory, continentId, countryId, width)
{
	var eventIdx = getEventIdx();

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
	for (var i = 0; i < filteredEvents.length; i++)
	{
		var eventObj = rankings.events[eventIdx[filteredEvents[i]]];
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
	for (var i = 0; i < rankings.continents.length; i++)
	{
		var continentObj = rankings.continents[i];

		if (filteredContinents.indexOf(rankings.continents[i].id) >= 0)
		{
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
	for (var i = 0; i < rankings.countries.length; i++)
	{
		if (filteredCountries.indexOf(rankings.countries[i].id) >= 0)
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

	var personIdx = getPersonIdx();
	var countryIdx = getCountryIdx();

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
					var personObj = rankings.persons[personIdx[rankObj.id]];
					var countryObj = rankings.countries[countryIdx[personObj.country]];

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
	
	var eventIdx = getEventIdx();
	var personIdx = getPersonIdx();
	var countryIdx = getCountryIdx();

	var eventObj = rankings.events[eventIdx[eventId]];
	
	for (var rankingIdx = 0; rankingIdx < eventObj.rankings.length; rankingIdx++)
	{
		var rankingObj = eventObj.rankings[rankingIdx];
		
		if (rankingObj.age == ageCategory && resultTypes.indexOf(rankingObj.type) < 0)
		{
			for (var rankIdx = 0; rankIdx < rankingObj.ranks.length; rankIdx++)
			{
				var rankObj = rankingObj.ranks[rankIdx];
				var personObj = rankings.persons[personIdx[rankObj.id]];
				var countryObj = rankings.countries[countryIdx[personObj.country]];

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
	
	var eventIdx = getEventIdx();
	var personIdx = getPersonIdx();
	var countryIdx = getCountryIdx();

	var eventObj = rankings.events[eventIdx[eventId]];
	
	for (var rankingIdx = 0; rankingIdx < eventObj.rankings.length; rankingIdx++)
	{
		var rankingObj = eventObj.rankings[rankingIdx];
		
		if (rankingObj.type == resultType && ageCategories.indexOf(rankingObj.age) < 0)
		{
			for (var rankIdx = 0; rankIdx < rankingObj.ranks.length; rankIdx++)
			{
				var rankObj = rankingObj.ranks[rankIdx];
				var personObj = rankings.persons[personIdx[rankObj.id]];
				var countryObj = rankings.countries[countryIdx[personObj.country]];

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

	var eventIdx = getEventIdx();
	var personIdx = getPersonIdx();
	var countryIdx = getCountryIdx();

	var eventObj = rankings.events[eventIdx[eventId]];

	for (var rankingIdx = 0; rankingIdx < eventObj.rankings.length; rankingIdx++)
	{
		var rankingObj = eventObj.rankings[rankingIdx];

		if (rankingObj.type == resultType && rankingObj.age == ageCategory)
		{
			for (var rankIdx = 0; rankIdx < rankingObj.ranks.length; rankIdx++)
			{
				var rankObj = rankingObj.ranks[rankIdx];
				var personObj = rankings.persons[personIdx[rankObj.id]];
				var countryObj = rankings.countries[countryIdx[personObj.country]];

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

	var eventIdx = getEventIdx();
	var personIdx = getPersonIdx();
	var countryIdx = getCountryIdx();

	var eventObj = rankings.events[eventIdx[eventId]];

	for (var rankingIdx = 0; rankingIdx < eventObj.rankings.length; rankingIdx++)
	{
		var rankingObj = eventObj.rankings[rankingIdx];

		if (rankingObj.type == resultType && rankingObj.age == ageCategory)
		{
			for (var rankIdx = 0; rankIdx < rankingObj.ranks.length; rankIdx++)
			{
				var rankObj = rankingObj.ranks[rankIdx];
				var personObj = rankings.persons[personIdx[rankObj.id]];
				var countryObj = rankings.countries[countryIdx[personObj.country]];

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

	var eventIdx = getEventIdx();
	var personIdx = getPersonIdx();
	var countryIdx = getCountryIdx();
	var competitionIdx = getCompetitionIdx();

	var eventObj = rankings.events[eventIdx[eventId]];
	
	for (var rankingIdx = 0; rankingIdx < eventObj.rankings.length; rankingIdx++)
	{
		var rankingObj = eventObj.rankings[rankingIdx];
		
		if (rankingObj.type == resultType && rankingObj.age == ageCategory)
		{
			out += '<div class="rankings"><table>';
			out += '<tr>';
			out += '<th class="rank">Rank</th>';
			out += '<th>Name</th>';
			out += '<th class="result">Result</th>';
			if (width >= IPHONE_LANDSCAPE)
			{
				out += '<th class="country">Citizen of</th>';
			}
			if (width >= IPAD_LANDSCAPE)
			{
				out += '<th class="competition">Competition</th>';
			}
			out += '</tr>';
			
			var missing = -1;
			var fakeRatio = 1;

			if (countryId != "XX")
			{
				if (rankingObj.missing.countries.hasOwnProperty(countryId))
				{
					missing = rankingObj.missing.countries[countryId];

					if (rankingObj.missing.hasOwnProperty("world") && rankingObj.missing.world > 0)
					{
						fakeRatio =  missing / rankingObj.missing.world;
					}
				}
			}
			else if (continentId != "XX")
			{
				if (rankingObj.missing.continents.hasOwnProperty(continentId))
				{
					missing = rankingObj.missing.continents[continentId];

					if (rankingObj.missing.hasOwnProperty("world") && rankingObj.missing.world > 0)
					{
						fakeRatio = missing / rankingObj.missing.world;
					}
				}
			}
			else
			{
				if (rankingObj.missing.hasOwnProperty("world"))
				{
					missing = rankingObj.missing.world;
				}
			}

			var fakeCount = 0;
			var filterCount = 0;
			var filterPrev = 0;

			for (var rankIdx = 0; rankIdx < rankingObj.ranks.length; rankIdx++)
			{
				var rankObj = rankingObj.ranks[rankIdx];
				var personObj = rankings.persons[personIdx[rankObj.id]];
				var countryObj = rankings.countries[countryIdx[personObj.country]];

				if (rankObj.id.startsWith("FAKE"))
				{
					fakeCount++;
				}

				if ((continentId == "XX" || countryObj.continent == continentId) &&
					(countryId == "XX" || countryObj.id == countryId))
				{
					var competitionObj = rankings.competitions[competitionIdx[rankObj.competition]];

					filterCount++;

					if (competitionObj.age <= 91)
					{
						out += '<tr class="highlight">';
					}
					else
					{
						out += '<tr>';
					}

					if (rankObj.id.startsWith("FAKE"))
					{
						fakeCount--;
						missing--;
					}

					if (rankObj.best != filterPrev)
					{
						var rank = 0;

						if (fakeCount > 0)
						{
							rank = filterCount + fakeRatio * fakeCount;
						}
						else
						{
							rank = filterCount + fakeRatio * (rankObj.rank - rankIdx - 1);
						}

						out += '<td class="rank">' + rank.toFixed(0) + '</td>';
					}
					else
					{
						out += '<td class="rank"></td>';
					}

					var href = personObj.name;
					if (!rankObj.id.startsWith("FAKE"))
					{
						href = '<a target="_blank" href="https://www.worldcubeassociation.org/persons/' + rankObj.id + '?event=' + eventId + '">' +
							(personObj.hasOwnProperty("deceased") ? '&#8224; ' : '') + personObj.name + '</a>';
					}

					if (width >= IPHONE_LANDSCAPE)
					{
						out += '<td>' + href + (rankObj.hasOwnProperty("age") ? ', ' + rankObj.age + '+' : '') + '</td>';
						out += '<td class="result">' + rankObj.best + '</td>';
						if (!rankObj.id.startsWith("FAKE"))
						{
							out += '<td><i class="flag flag-' + countryObj.id + '"></i>&nbsp;' + countryObj.name + '</td>';
						}
						else
						{
							out += '<td></td>';
						}

						if (width >= IPAD_LANDSCAPE)
						{
							var compCountryObj = rankings.countries[countryIdx[competitionObj.country]];

							if (!rankObj.id.startsWith("FAKE"))
							{
								out += '<td><i class="flag flag-' + compCountryObj.id + '"></i>&nbsp;' +
									'<a target="_blank" href="https://www.worldcubeassociation.org/competitions/' + competitionObj.webId + '/results/by_person#' + personObj.id + '">' +
									competitionObj.name + '</a></td>';
							}
							else
							{
								out += '<td></td>';
							}
						}
					}
					else
					{
						if (!rankObj.id.startsWith("FAKE"))
						{
							out += '<td>' + href + '<br/><i class="flag flag-' + countryObj.id + '"></i>&nbsp;' + countryObj.name +
								(rankObj.hasOwnProperty("age") ? ', ' + rankObj.age + '+' : '') + '</td>';
						}
						else
						{
							out += '<td>' + href + '</td>';
						}
						out += '<td class="result">' + rankObj.best + '</td>';
					}
					out += '</tr>';

					filterPrev = rankObj.best;
				}
			}

			out += '</table></div>';

			if (missing >= 0)
			{
				out += '<p>' + filterCount + ' of ' + (filterCount + missing) + ' seniors listed.</p>';
				out += '<p>Overall completeness of rankings = ' + (100 * filterCount / (filterCount + missing)).toFixed(1) + '%</p>';
			}
			else
			{
				out += '<p>' + filterCount + ' seniors listed.</p>';
				out += '<p>NOTE: The actual number of seniors for this region is unknown.</p>';
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
	
	// Psuedo dictionary
	var eventIdx = getEventIdx();
	
	// Determine the event
	var eventId = hashParts[0].length > 0 ? hashParts[0] : rankings.events[0].id;
	var resultType = hashParts.length > 1 && hashParts[1].length > 0 ? hashParts[1].toLowerCase() : "single";
	var ageCategory = hashParts.length > 2 && hashParts[2].length > 0 ? hashParts[2] : "40";
	var continentId = hashParts.length > 3 && hashParts[3].length > 0 ? hashParts[3].toUpperCase() : "XX";
	var countryId = hashParts.length > 4 && hashParts[4].length > 0 ? hashParts[4].toUpperCase() : "XX";
	
	// Check if the event exists
	if (eventIdx.hasOwnProperty(eventId) >= 0)
	{
		var eventObj = rankings.events[eventIdx[eventId]];

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
