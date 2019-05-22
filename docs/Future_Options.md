# Unofficial Senior Rankings

## Introduction

The [Unofficial Senior Rankings](https://logiqx.github.io/wca-ipy/) have been evolving since 2015 and have been rapidly growing in popularity over the past few months. They are unofficial rankings for the senior cubing community, produced from official WCA competition results.

The main artefact of the project is known as the [Partial Over 40s Rankings](https://logiqx.github.io/wca-ipy/Partial_Rankings.html) and currently includes around 200 competitors. The current completeness of the Over 40s Rankings can be summarised as follows:

>**Percentage coverage for 3x3x3**  
>90% of sub-15 | 50% of sub-20 | 43% of sub-25 | 34% of sub-30 | 25% of sub-45 | 21% of sub-1:00  
>
>**3x3x3 variations have greater coverage**  
>OH: 70% of sub-0:40 | 3BLD: 80% of sub-4:00 | Feet: 100% of sub-4:00 | FMC: 100% of sub-40  
>
>**Big cubes have even greater coverage**  
>4x4: 75% of sub-1:30 | 5x5: 85% of sub-3:00 | 6x6: 95% of sub-6:00 | 7x7: 100% of sub-9:00

The statistics above make it clear that most of the fastest seniors are included in the unofficial rankings.


## Project Goals

The project has three main goals:

1. We wish to provide senior rankings to the community - Over 40s, Over 50s, Over 60s, etc.
2. We wish to provide accurate rankings, regardless of how many names are actually listed.
3. We wish to protect the privacy of competitors who have not yet provided their consent.

The project in it's current form satisfies the first goal reasonably well due to the coverage that we have for the faster competitors. It falls short on the second goal due to the number of competitors that are missing from the rankings. The project team has also been taking privacy very seriously and recently added a [Privacy Statement](http://logiqx.github.io/wca-ipy/Privacy_Notice.html).

Until such time as official senior rankings become available on the official WCA website, it is clear that the unofficial senior rankings will continue to be of benefit to the senior cubing community. In order to satisfy demand from the senior community the project is looking to make some improvements to what is currently provided in the way of rankings.

Specifically, we wish to show accurate rankings despite there being some competitors missing from the rankings. For example the partial rankings for [3x3x3 OH](http://logiqx.github.io/wca-ipy/Partial_Rankings.html#averages) average currently show the following:

| **Rank** | **Person**                                                   | **Result** |
| -------- | ------------------------------------------------------------ | ---------- |
| 1        | [Dave Campbell](https://www.worldcubeassociation.org/persons/2005CAMP01#333oh), Canada | 22.61      |
| 2        | [Michael George](https://www.worldcubeassociation.org/persons/2015GEOR02#333oh), United Kingdom | 25.45      |
| 3        | [Teller Coates](https://www.worldcubeassociation.org/persons/2010COAT01#333oh), United States | 25.46      |
| 4        | [Stefan Lidström](https://www.worldcubeassociation.org/persons/2008LIDS01#333oh), Sweden | 27.12      |

However, It is known that there is a missing 22.xx second (ranking 1st or 2nd) PR average and a missing 26.xx PR average (ranking 5th), although the identifies of those competitors are unknown.

## Legal Basis

Unofficial senior rankings can be considered to be a "legitimate interest" under GDPR.

Article 6(1)(f) of GDPR provides a lawful basis for processing where:

> “processing is necessary for the purposes of the legitimate interests pursued by the controller or by a third party except where such interests are overridden by the interests or fundamental rights and freedoms of the data subject which require protection of personal data, in particular where the data subject is a child.”

An overview of legitimate interests is available on the [Information Commissioner's Office](https://ico.org.uk/for-organisations/guide-to-data-protection/guide-to-the-general-data-protection-regulation-gdpr/lawful-basis-for-processing/legitimate-interests/) (ICO) website.

Feedback about the senior rankings has always been very positive, appreciative and many of the competitors are wildly enthusiastic about the unofficial senior rankings!

Nobody has ever declined to be included in the senior rankings. Nobody has ever complained and nobody has ever asked to be removed.


## Proposal

Three possible options are being proposed to tackle the issue of people missing from the unofficial senior rankings. All of the options require simple SQL extracts to be run on the WCA server from which the senior rankings team can produce the various reports on a daily basis.

The SQL that produces the CSV files for the current project is hosted on GitHub - [extract_senior_details.sql](https://github.com/Logiqx/wca-ipy/blob/master/sql/extract_senior_details.sql)

If this SQL script is run against the WCA database and the extracts made available as a private download, existing project code can be used to produce improved senior rankings. The existing reports can even be run without the need for MySQL or MariaDB since they work directly from the CSV extracts.

Three CSV extracts are used to produce the [Partial Over 40s Rankings](http://logiqx.github.io/wca-ipy/Partial_Rankings.html).

* [known_senior_details.csv](https://github.com/Logiqx/wca-ipy/blob/master/data/public/extract/known_senior_details.csv) - WCA ID, name and age category when they last competed

* [known_senior_averages.csv](https://github.com/Logiqx/wca-ipy/blob/master/data/public/extract/known_senior_averages.csv) - Event, WCA ID, PR average and age category

* [known_senior_singles.csv](https://github.com/Logiqx/wca-ipy/blob/master/data/public/extract/known_senior_singles.csv) - Event, WCA ID, PR single and age category

It should be noted that the CSV extracts do NOT include DOB information, only age categories 40+, 50+, 60+, 70+, 80+.

None of the options described in this proposal require the WCA to provide DOB information to the senior rankings team.

### Option 1

Using the CSV extracts described in the previous section, existing code can be used to produce improved senior rankings, showing complete rankings by masking the names of competitors who are yet to provide their consent to the senior rankings team.

For example the [3x3x3 OH](http://logiqx.github.io/wca-ipy/Partial_Rankings.html#averages) average rankings would show the following:

| **Rank** | **Person**                                                   | **Result** |
| -------- | ------------------------------------------------------------ | ---------- |
| 1        | [Dave Campbell](https://www.worldcubeassociation.org/persons/2005CAMP01#333oh), Canada | 22.61      |
| 2        | -                                                            | 22.xx      |
| 3        | [Michael George](https://www.worldcubeassociation.org/persons/2015GEOR02#333oh), United Kingdom | 25.45      |
| 4        | [Teller Coates](https://www.worldcubeassociation.org/persons/2010COAT01#333oh), United States | 25.46      |
| 5        | -                                                            | 26.xx      |
| 6        | [Stefan Lidström](https://www.worldcubeassociation.org/persons/2008LIDS01#333oh), Sweden | 27.12      |

Note: The rankings are to all intents and purposes complete, albeit with some names and results masked.

This is the favoured option in this proposal, based on a suitable agreement being signed, guaranteeing that WCA IDs of senior competitors will not be shared with anyone or used for purposes other than the senior rankings. This agreement could be part of the [Legitimate Interest Assessment](https://ico.org.uk/for-organisations/guide-to-data-protection/guide-to-the-general-data-protection-regulation-gdpr/legitimate-interests/how-do-we-apply-legitimate-interests-in-practice/) (LIA).

### Option 2

The second option is much like the first, except that it would completely suppress the names and results of people who have yet to provide their consent to the senior rankings team.

For example the [3x3x3 OH](http://logiqx.github.io/wca-ipy/Partial_Rankings.html#averages) average rankings would show the following:

| **Rank** | **Person**                                                   | **Result** |
| -------- | ------------------------------------------------------------ | ---------- |
| 1        | [Dave Campbell](https://www.worldcubeassociation.org/persons/2005CAMP01#333oh), Canada | 22.61      |
| 3        | [Michael George](https://www.worldcubeassociation.org/persons/2015GEOR02#333oh), United Kingdom | 25.45      |
| 4        | [Teller Coates](https://www.worldcubeassociation.org/persons/2010COAT01#333oh), United States | 25.46      |
| 6        | [Stefan Lidström](https://www.worldcubeassociation.org/persons/2008LIDS01#333oh), Sweden | 27.12      |

Note: Although the names and results for 2nd and 5th are missing the ranks 1, 3, 4, 6 are still correct.

This is second most favoured option in this proposal, based on a suitable agreement being signed, guaranteeing that WCA IDs of senior competitors will not be shared with anyone or used for purposes other than the senior rankings. This agreement could be part of the [Legitimate Interest Assessment](https://ico.org.uk/for-organisations/guide-to-data-protection/guide-to-the-general-data-protection-regulation-gdpr/legitimate-interests/how-do-we-apply-legitimate-interests-in-practice/) (LIA).

### Option 3

The third option is in the instance where the WCA are uncomfortable revealing senior competitors to a third party such as the senior rankings team. The third option is much like the second except it would use a modified SQL script to suppress the people who have yet to provide their consent to the senior rankings team. The CSV extracts would only contain the details of people how have already provided their consent to the senior rankings team.

The [3x3x3 OH](http://logiqx.github.io/wca-ipy/Partial_Rankings.html#averages) average rankings would be identical to option 2:

| **Rank** | **Person**                                                   | **Result** |
| -------- | ------------------------------------------------------------ | ---------- |
| 1        | [Dave Campbell](https://www.worldcubeassociation.org/persons/2005CAMP01#333oh), Canada | 22.61      |
| 3        | [Michael George](https://www.worldcubeassociation.org/persons/2015GEOR02#333oh), United Kingdom | 25.45      |
| 4        | [Teller Coates](https://www.worldcubeassociation.org/persons/2010COAT01#333oh), United States | 25.46      |
| 6        | [Stefan Lidström](https://www.worldcubeassociation.org/persons/2008LIDS01#333oh), Sweden | 27.12      |

Note: Although the names and results for 2nd and 5th are missing the ranks 1, 3, 4, 6 are still correct.

The implementation of option 3 is slightly more complex than the first two options. In addition to excluding the competitors who have yet to provide their consent, rankings would have to be calculated within the SQL by using window functions or temporary variables. Multiple datasets would also have to be produced by the SQL script; Over 40s, Over 50s, Over 60s, Over 70s, Over 80s.

This option has two obvious downsides:

1. Firstly, the SQL script to generate Over 40s, Over 50s ... Over 80s would need to run multiple queries and combine the results. This is not the end of the world but it would take several times longer to run; possible minutes rather than 10s of seconds.

2. Secondly and most significantly is that an updated SQL script would need to be provided to the WCA team every time a new competitor provides (or removes) their consent. It would make the consent process a lot more clunky and place more burden on everybody involved.

Due to the downsides this is the least favoured of the three options. It does however have the benefit that new additional seniors will be disclosed to the senior rankings team.

## Summary

All three options allow improved senior rankings to be produced, tackling the limitations of the existing project. Implementing any of the options will mean the project meets all three goals:

1. Provide senior rankings
2. Provide accurate rankings
3. Protect privacy

There is no need for any DOB information in order to produce improved senior rankings and nobody will ever appear in the senior rankings without providing their consent. This can be guaranteed through the signing of an agreement between the WCA and the senior rankings team; see the LIA references earlier.

All three options improve upon the existing [partial rankings](http://logiqx.github.io/wca-ipy/Partial_Rankings.html) whilst continuing to exclude protect the privacy of individuals who have yet to provide their consent to the senior rankings team.

Options 2 and 3 are consistent with the proposal for [official senior rankings](https://logiqx.github.io/wca-ipy/WCA_Proposal.html) on the WCA website, submitted in February 2019.

Whilst none of the options are intended to replace or supersede the proposal for official senior rankings, they do offer a very good interim solution with minimal effort from the WCA and senior rankings team.

