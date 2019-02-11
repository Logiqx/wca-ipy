# List of recognised events
events = \
[
    ('333', '3x3x3 Cube', '10', 'time', 180),
    ('222', '2x2x2 Cube', '20', 'time', 60),
    ('444', '4x4x4 Cube', '30', 'time', 180),
    ('555', '5x5x5 Cube', '40', 'time', 240),
    ('666', '6x6x6 Cube', '50', 'time', 360),
    ('777', '7x7x7 Cube', '60', 'time', 540),
    ('333bf', '3x3x3 Blindfolded', '70', 'time', 240),
    ('333fm', '3x3x3 Fewest Moves', '80', 'number', 60),
    ('333oh', '3x3x3 One-Handed', '90', 'time', 120),
    ('333ft', '3x3x3 With Feet', '100', 'time', 240),
    ('clock', 'Clock', '110', 'time', 60),
    ('minx', 'Megaminx', '120', 'time', 240),
    ('pyram', 'Pyraminx', '130', 'time', 60),
    ('skewb', 'Skewb', '140', 'time', 60),
    ('sq1', 'Square-1', '150', 'time', 120),
    ('444bf', '4x4x4 Blindfolded', '160', 'time', 0),
    ('555bf', '5x5x5 Blindfolded', '170', 'time', 0),
    ('333mbf', '3x3x3 Multi-Blind', '180', 'multi', 0)
]

# Create dictionary of events
eventsDict = {}
for event in events:
    eventsDict[event[0]] = (event[1:])


def formatTime(seconds):
    '''Intelligently convert seconds to hours, minutes and seconds'''
    if seconds >= 3600:
        return str(seconds / 3600) + ':' + str(seconds % 3600 / 60).zfill(2) + ':' + str(seconds % 60).zfill(2)
    elif seconds >= 60:
        return str(seconds / 60) + ':' + str(seconds % 60).zfill(2)
    else:
        return str(seconds)


def decodeTime(result):
    '''Intelligently convert hours, minutes and seconds to seconds'''
    seconds = 0
    parts = result.split(':')

    for part in parts:
        seconds = seconds * 60 + int(part)

    return seconds
