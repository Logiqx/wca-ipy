//
// Render the case
//
function renderPerson(hashParts, width)
{
	// Initialisation
	var out = "";
	
	// Array is used instead of Map() which doesn't work on my iPad
	var personIds = getPersonIds();

	// Determine the person
	if (hashParts[0] == "random")
	{
		personId = personIds[Math.floor(Math.random() * personIds.length)];
	}
	else
	{
		personId = hashParts[0]
	}
	
	// Check if the person exists
	if (personIds.indexOf(personId) >= 0)
	{
		// Get the actual case
		var personObj = rankings.persons[personIds.indexOf(personId)];

		out += "<h2>" + personObj.name + "</h2>";
		
		// Browser title
		document.title = personObj.name;

		// WIP
		out += hashParts;

		// Output header message
		out += header();
			
		// Output footer message
		out += footer();	
	}
	else
	{
		out += parameterMessage('person', personId);
	}

	// Update the HTML
	document.getElementById("container").innerHTML = out;
}

