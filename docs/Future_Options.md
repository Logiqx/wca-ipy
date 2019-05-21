# Senior Rankings

## Overview

We have three basic requirements:

1. We wish to have senior rankings - Over 40s, Over 50s, Over 60s, etc.

2. We wish to show actual rankings, regardless of how many people are actually listed

3. We wish to protect the identities of competitors who have not provided their consent

### Future Options

Two options have clearly formed in my mind. Neither option requires the WCA to provide me with DOB information. Both options are based on the WCA running SQL on their server and providing me with the outputs so that I can produce the senior rankings. The extract can be identical to the one I generate for the [partial rankings](http://logiqx.github.io/wca-ipy/Partial_Rankings.html).

An example of the intermediate CSV can be viewed on GitHub: [known_senior_averages.csv](https://github.com/Logiqx/wca-ipy/blob/master/data/public/extract/known_senior_averages.csv)

### Option 1

The SQL that produces the intermediate CSV file is the second query in this script: [extract_senior_details.sql](https://github.com/Logiqx/wca-ipy/blob/master/sql/extract_senior_details.sql)

If the last two queries are run on the WCA server and the outputs are provided to me, I can process them using my existing code whilst suppressing the people who have not given me their consent. The result would be identical to the existing [partial rankings](http://logiqx.github.io/wca-ipy/Partial_Rankings.html) except the rank numbers would be 100% accurate.

There would be gaps in the numbering but all rankings would represent the actual ranking amongst all senior competitors.

This is my preferred proposal and I would be happy to sign any legal document that should be required, agreeing that I will not share the WCA IDs with anyone or use them for purposes other than these rankings.

Note: The intermediate CSV will not include DOB information, I do not require it from the WCA.

### Option 2

My second proposal would be to modify the SQL to filter out the people who have not given their consent and calculate the rankings within the SQL. A smaller file would therefore be provided by the WCA, including only the results of competitors who have opted into my rankings.

This second approach has two downsides though.

1. Firstly, I'd have to tweak the script to generate Over 40s, Over 50s ... Over 80s using multiple queries and combine the results. This is not the end of the world but it would take several times longer to run; possible minutes rather than 10s of seconds.

2. Secondly and most significantly is that I'd have to provide updated SQL to the WCA when new people give me their consent to be included. It would make the consent process a lot more clunky and place more burden on everybody involved.

Due to the downsides described above, option 1 would be my strongest preference.

## Summary

The end result of both options addresses the three requirements described earlier:

1. Senior rankings - YES
2. Actual rankings - YES
3. Protect privacy - YES

I will not receive any DOB information in order to produce the rankings and nobody will appear in the senior rankings without providing their consent

Both options provide the same level of information in my [partial rankings](http://logiqx.github.io/wca-ipy/Partial_Rankings.html), whilst omitting competitors who have not provided their consent.

The reports will be consistent with the proposal for official senior rankings, submitted in February this year.

