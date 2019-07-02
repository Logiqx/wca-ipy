# Future Options

## Introduction

The [Unofficial Senior Rankings](https://logiqx.github.io/wca-ipy/) have been evolving since 2015 and have been rapidly growing in popularity over the past few months. They are unofficial rankings for the senior cubing community, produced from official WCA competition results.

The main artefact of the project is known as the [Partial Over 40s Rankings](https://logiqx.github.io/wca-ipy/Partial_Rankings.html) which currently includes around 200 senior competitors. The completeness of the Over 40s Rankings can be summarised as follows:

>**Percentage coverage for 3x3x3**  
>90% of sub-15 | 60% of sub-20 | 50% of sub-25 | 43% of sub-30 | 37% of sub-45 | 33% of sub-1:00  
>
>**3x3x3 variations have greater coverage**  
>OH: 70% of sub-0:40 | 3BLD: 75% of sub-4:00 | Feet: 90% of sub-4:00 | FMC: 95% of sub-40  
>
>**Big cubes have even greater coverage**  
>4x4: 80% of sub-1:30 | 5x5: 85% of sub-3:00 | 6x6: 90% of sub-6:00 | 7x7: 95% of sub-9:00

These statistics make it clear that most of the fastest seniors are included in the unofficial rankings but we are still missing a large number of "typical" senior competitors.

## Lawful Basis

Unofficial senior rankings may be regarded as a "legitimate interest" under GDPR.

Article 6(1)(f) of GDPR provides a lawful basis for processing where:

> “processing is necessary for the purposes of the legitimate interests pursued by the controller or by a third party except where such interests are overridden by the interests or fundamental rights and freedoms of the data subject which require protection of personal data, in particular where the data subject is a child.”

An overview of legitimate interests is available on the [Information Commissioner's Office](https://ico.org.uk/for-organisations/guide-to-data-protection/guide-to-the-general-data-protection-regulation-gdpr/lawful-basis-for-processing/legitimate-interests/) (ICO) website.

The project team takes privacy very seriously and have created a [Privacy Statement](http://logiqx.github.io/wca-ipy/Privacy_Notice.html) which provides all necessary information to people listed in the rankings.

Feedback about the senior rankings has always been very positive, appreciative and many of the competitors are wildly enthusiastic about the unofficial senior rankings. There is an undeniable interest!

Requests to be added to the rankings come from around the world, largely spread by via the internet or word of mouth at WCA competitions. Nobody has ever declined to be included in the senior rankings. Nobody has ever complained and nobody has ever asked to be removed.

We do not publish DOB information for competitors, only the age categories 40+, 50+, 60+, etc.

## Project Goals

The senior rankings project has three main goals:

1. We aim to provide senior rankings to the community - Over 40s, Over 50s, Over 60s, Over 70, Over 80s.
2. We aim to provide accurate rankings, regardless of how many names are actually listed.
3. We aim to respect and protect the privacy of competitors who have not yet provided their consent.

The project in its current form satisfies the first goal reasonably well due to the coverage that we have for the faster competitors. It falls short on the second goal due to the number of competitors that are missing from the rankings. The project team has also been taking privacy very seriously and has provided a [Privacy Statement](http://logiqx.github.io/wca-ipy/Privacy_Notice.html) giving full transparency about the use of data since early in 2019.

Until such time as official senior rankings become available on the official WCA website, it is clear that the unofficial senior rankings will continue to be of benefit to the senior cubing community. In order to satisfy the demands of the senior community the project is looking to make some notable improvements to what is currently provided in the way of rankings.

Specifically, we wish to show accurate rankings despite there being some names missing / unknown. For example the partial rankings for 3x3x3 OH average currently show the following:

| **Rank** | **Person**                                                   | **Result** |
| -------- | ------------------------------------------------------------ | ---------- |
| 1        | Dave Campbell, Canada | 22.61      |
| 2        | Michael George, United Kingdom | 25.45      |
| 3        | Teller Coates, United States | 25.46      |
| 4        | Stefan Lidström, Sweden | 27.12      |

However, it is known that these rankings are missing a 22.xx PR average (ranking 1st or 2nd) and 26.xx PR average (ranking 5th), only the identifies of those competitors are unknown.

The project team have created an interim solution called the "[Indicative Over 40s Rankings](https://logiqx.github.io/wca-ipy/Indicative_Rankings.html)" to give seniors a more realistic idea of how they rank worldwide. The indicative rankings utilise the known distributions of senior results as of Feb 2019 (one-off [extract](https://github.com/Logiqx/wca-ipy/blob/master/sql/extract_senior_aggs.sql) provided by the WCA) and the growth of the WCA since the extract in Feb 2019.


## Proposal

Three possible options are being proposed to tackle the issue of people missing from the unofficial senior rankings. All of the proposed options are based on simple SQL extracts being run on the WCA server from which the senior rankings team can produce the various reports, ideally on a daily basis.

The SQL that produces the CSV files for the current rankings is hosted on GitHub - [extract_senior_results.sql](https://github.com/Logiqx/wca-ipy/blob/master/sql/extract_senior_results.sql)

If this SQL script were to be run against the WCA database and the extracts made available as a private download, existing code can be used to produce accurate senior rankings. The existing code can even be run without the need for MySQL or MariaDB since it relies solely on the CSV extracts.

A tiny machine could be set up on [Amazon Web Services (AWS)](https://aws.amazon.com/) by the senior rankings team to automatically refresh the senior rankings on a daily basis.

Three CSV extracts that are used to produce the existing rankings are as follows:

* known_senior_details.csv - WCA ID, name and age category
* known_senior_averages.csv - Event ID, WCA ID, PR average and age category
* known_senior_singles.csv - Event ID, WCA ID, PR single and age category

It should be noted that the CSV extracts do NOT include DOB information, only age categories; 40+, 50+, 60+, etc.

None of the options described in this proposal require the WCA to provide DOB information to the senior rankings team.

### Option 1

Using the three CSV extracts described earlier, existing project code can be run to produce improved senior rankings, showing complete rankings but masking the names and results of competitors who are yet to provide their consent to the senior rankings team.

For example the 3x3x3 OH average rankings would show the following:

| **Rank** | **Person**                                                   | **Result** |
| -------- | ------------------------------------------------------------ | ---------- |
| 1        | Dave Campbell, Canada | 22.61      |
| 2        | -                                                            | 22.xx      |
| 3        | Michael George, United Kingdom | 25.45      |
| 4        | Teller Coates, United States | 25.46      |
| 5        | -                                                            | 26.xx      |
| 6        | Stefan Lidström, Sweden | 27.12      |

Note: The rankings are to all intents and purposes complete, albeit with some names and results masked.

This is the favoured option in this proposal and if required, including a suitable agreement, guaranteeing that WCA IDs of senior competitors will not be shared with anyone outside of the senior rankings team or used for purposes other than the senior rankings. This agreement could be part of a [Legitimate Interests Assessment](https://ico.org.uk/for-organisations/guide-to-data-protection/guide-to-the-general-data-protection-regulation-gdpr/legitimate-interests/how-do-we-apply-legitimate-interests-in-practice/) (LIA), providing a light-touch audit trail of the decisions and justification for processing on the basis of legitimate interests.

### Option 2

The second option is similar to the first and would utilise the same CSV extracts as option 1. The only difference is that the code to generate the reports would suppress the names and results of people who have yet to provide their consent to the senior rankings team.

For example the 3x3x3 OH average rankings would show the following:

| **Rank** | **Person**                                                   | **Result** |
| -------- | ------------------------------------------------------------ | ---------- |
| 1        | Dave Campbell, Canada | 22.61      |
| 3        | Michael George, United Kingdom | 25.45      |
| 4        | Teller Coates, United States | 25.46      |
| 6        | Stefan Lidström, Sweden | 27.12      |

Note: Although the names and results for 2nd and 5th place are missing the rankings 1, 3, 4 and 6 are still accurate.

This is the second favoured option in this proposal and if required, including a suitable agreement, guaranteeing that WCA IDs of senior competitors will not be shared with anyone outside of the senior rankings team or used for purposes other than the senior rankings. This agreement could be part of a [Legitimate Interests Assessment](https://ico.org.uk/for-organisations/guide-to-data-protection/guide-to-the-general-data-protection-regulation-gdpr/legitimate-interests/how-do-we-apply-legitimate-interests-in-practice/) (LIA), providing a light-touch audit trail of the decisions and justification for processing on the basis of legitimate interests.

### Option 3

The third option is similar to the second but would use [aggregated](https://github.com/Logiqx/wca-ipy/blob/master/sql/extract_senior_aggs.sql) senior results from the WCA database. This approach is essentially the same as the existing "[Indicative Over 40s Rankings](https://logiqx.github.io/wca-ipy/Indicative_Rankings.html)" but using up-to-date distributions of senior results.

The indicative rankings basically spread out the unknowns such that a sole 25.x is regarded as 25.50, two 25.x results are regarded as 25.25 + 25.75, three 25.x results are regarded as 25.17 + 25.50 + 25.83 etc.

For example the 3x3x3 OH average rankings would show the following:

| **Rank** | **Person**                     | **Result** |
| -------- | ------------------------------ | ---------- |
| 2        | Dave Campbell, Canada          | 22.61      |
| 3        | Michael George, United Kingdom | 25.45      |
| 4        | Teller Coates, United States   | 25.46      |
| 6        | Stefan Lidström, Sweden        | 27.12      |

Note: Although the names and results for 1st and 5th place are missing the rankings 3, 4 and 6 are still accurate.

This is the least favoured option since the unknown results are only known to the nearest second and must therefore be spread out as described earlier (e.g. one 25.x assumed to be 25.50).

The main benefit of this option is that it does not disclose the identities of seniors to the senior rankings team, should that knowledge be seen as an issue.

## Conclusion

All three options will allow improved senior rankings to be produced for the senior community, tackling the issue of non-listed competitors.

Implementing any one of the options will allow the senior rankings team to further meet the project goals:

1. Provide senior rankings - yes, ongoing
2. Provide accurate rankings - yes, vastly improved
3. Protect privacy - yes, ongoing

All three options can improve the existing reports by showing accurate rankings, whilst continuing to protect the privacy of individuals who have yet to provide their consent to the senior rankings team.

There is no need for DOB information to be provided to the senior rankings team and nobody will ever appear in the senior rankings without providing their consent to the senior rankings team.

Extracts provided to the senior rankings team will not be made public and the only names that will be listed will be as described in this proposal.

## Recommendations

Whilst none of the options in this proposal are intended to replace or supersede the proposal for [Official Senior Rankings](https://logiqx.github.io/wca-ipy/WCA_Proposal.html), they do offer an effective interim solution with minimal effort on the part of the WCA or the senior rankings team.

The necessary code already exists on GitHub so it could easily be scheduled to run on a regular basis. The required activities would be as follows:

1. Completion of the [Legitimate Interests Assessment](https://ico.org.uk/for-organisations/guide-to-data-protection/guide-to-the-general-data-protection-regulation-gdpr/legitimate-interests/how-do-we-apply-legitimate-interests-in-practice/) (LIA) - WCA Data Protection Committee (WDPC)
2. Scheduling the SQL extracts ([results](https://github.com/Logiqx/wca-ipy/blob/master/sql/extract_senior_results.sql) or [aggregations](https://github.com/Logiqx/wca-ipy/blob/master/sql/extract_senior_aggs.sql)) - WCA Results Team (WRT) / WCA Software Team (WST)
3. Creation of a machine on [AWS](https://aws.amazon.com/) to refresh the rankings - Senior Rankings Team

Finally, it is worth saying that it is still hoped that the earlier [proposal](https://github.com/Logiqx/wca-ipy/blob/master/docs/WCA_Proposal.md) for official senior rankings will one day become a reality.

The interim proposal can potentially be implemented in a matter of days or weeks whereas the proposal for official rankings seems likely to take months or even years.

