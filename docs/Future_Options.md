# Future Options

## Introduction

The [Unofficial Senior Rankings](https://logiqx.github.io/wca-ipy/) have been evolving since 2015 and have been rapidly growing in popularity over the past few months. They are unofficial rankings for the senior cubing community, produced from official WCA competition results.

The main artefact of the project is known as the [Partial Over 40s Rankings](https://logiqx.github.io/wca-ipy/Partial_Rankings.html) which currently includes around 200 senior competitors. The completeness of the Over 40s Rankings can be summarised as follows:

>**Percentage coverage for 3x3x3**  
>90% of sub-15 | 50% of sub-20 | 43% of sub-25 | 34% of sub-30 | 25% of sub-45 | 21% of sub-1:00  
>
>**3x3x3 variations have greater coverage**  
>OH: 70% of sub-0:40 | 3BLD: 80% of sub-4:00 | Feet: 100% of sub-4:00 | FMC: 100% of sub-40  
>
>**Big cubes have even greater coverage**  
>4x4: 75% of sub-1:30 | 5x5: 85% of sub-3:00 | 6x6: 95% of sub-6:00 | 7x7: 100% of sub-9:00

These statistics make it clear that most of the fastest seniors are included in the unofficial rankings.

## Lawful Basis

Unofficial senior rankings can be regarded as a "legitimate interest" under GDPR.

Article 6(1)(f) of GDPR provides a lawful basis for processing where:

> “processing is necessary for the purposes of the legitimate interests pursued by the controller or by a third party except where such interests are overridden by the interests or fundamental rights and freedoms of the data subject which require protection of personal data, in particular where the data subject is a child.”

An overview of legitimate interests is available on the [Information Commissioner's Office](https://ico.org.uk/for-organisations/guide-to-data-protection/guide-to-the-general-data-protection-regulation-gdpr/lawful-basis-for-processing/legitimate-interests/) (ICO) website.

Feedback about the senior rankings has always been very positive, appreciative and many of the competitors are wildly enthusiastic about the unofficial senior rankings. There is an undeniable interest!

Nobody has ever declined to be included in the senior rankings. Nobody has ever complained and nobody has ever asked to be removed.

We do not publish DOB information for competitors, only the age categories 40+, 50+, 60+, etc.

## Project Goals

The senior rankings project has three main goals:

1. We aim to provide senior rankings to the community - Over 40s, Over 50s, Over 60s, Over 70, Over 80s.
2. We aim to provide accurate rankings, regardless of how many names are actually listed.
3. We aim to respect and protect the privacy of competitors who have not yet provided their consent.

The project in its current form satisfies the first goal reasonably well due to the coverage that we have for the faster competitors. It falls short on the second goal due to the number of competitors that are missing from the rankings. The project team has also been taking privacy very seriously and recently added a [Privacy Statement](http://logiqx.github.io/wca-ipy/Privacy_Notice.html) to provide further transparency.

Until such time as official senior rankings become available on the official WCA website, it is clear that the unofficial senior rankings will continue to be of benefit to the senior cubing community. In order to satisfy the demands of the senior community the project is looking to make some notable improvements to what is currently provided in the way of rankings.

Specifically, we wish to show accurate rankings despite there being some names missing / unknown. For example the partial rankings for 3x3x3 OH average currently show the following:

| **Rank** | **Person**                                                   | **Result** |
| -------- | ------------------------------------------------------------ | ---------- |
| 1        | Dave Campbell, Canada | 22.61      |
| 2        | Michael George, United Kingdom | 25.45      |
| 3        | Teller Coates, United States | 25.46      |
| 4        | Stefan Lidström, Sweden | 27.12      |

However, it is known that these rankings are missing a 22.xx PR average (ranking 1st or 2nd) and 26.xx PR average (ranking 5th), only the identifies of those competitors are unknown.


## Proposal

Three possible options are being proposed to tackle the issue of people missing from the unofficial senior rankings. All of the proposed options are based on simple SQL extracts being run on the WCA server from which the senior rankings team can produce the various reports, ideally on a daily basis.

The SQL that produces the CSV files for the current rankings is hosted on GitHub - [extract_senior_details.sql](https://github.com/Logiqx/wca-ipy/blob/master/sql/extract_senior_details.sql)

If this SQL script were to be run against the WCA database and the extracts made available as a private download, existing code can be used to produce accurate senior rankings. The existing code can even be run without the need for MySQL or MariaDB since it relies solely on the CSV extracts.

A tiny machine could be set up on [Amazon Web Services (AWS)](https://aws.amazon.com/) by the senior rankings team to automatically refresh the senior rankings on a daily basis.

Three CSV extracts that are used to produce the existing rankings are as follows:

* [known_senior_details.csv](https://github.com/Logiqx/wca-ipy/blob/master/data/public/extract/known_senior_details.csv) - WCA ID, name and age category
* [known_senior_averages.csv](https://github.com/Logiqx/wca-ipy/blob/master/data/public/extract/known_senior_averages.csv) - Event ID, WCA ID, PR average and age category
* [known_senior_singles.csv](https://github.com/Logiqx/wca-ipy/blob/master/data/public/extract/known_senior_singles.csv) - Event ID, WCA ID, PR single and age category

It should be noted that the CSV extracts do NOT include any DOB information, only age categories; 40+, 50+, 60+, etc.

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

The second option is similar to the first and would utilise the same CSV extracts as option 1. The difference is that the code to generate the reports would suppress the names and results of people who have yet to provide their consent to the senior rankings team.

For example the 3x3x3 OH average rankings would show the following:

| **Rank** | **Person**                                                   | **Result** |
| -------- | ------------------------------------------------------------ | ---------- |
| 1        | Dave Campbell, Canada | 22.61      |
| 3        | Michael George, United Kingdom | 25.45      |
| 4        | Teller Coates, United States | 25.46      |
| 6        | Stefan Lidström, Sweden | 27.12      |

Note: Although the names and results for 2nd and 5th place are missing the rankings 1, 3, 4 and 6 are still accurate.

This is the second most favoured option in this proposal and if required, including a suitable agreement, guaranteeing that WCA IDs of senior competitors will not be shared with anyone outside of the senior rankings team or used for purposes other than the senior rankings. This agreement could be part of a [Legitimate Interests Assessment](https://ico.org.uk/for-organisations/guide-to-data-protection/guide-to-the-general-data-protection-regulation-gdpr/legitimate-interests/how-do-we-apply-legitimate-interests-in-practice/) (LIA), providing a light-touch audit trail of the decisions and justification for processing on the basis of legitimate interests.

### Option 3

The third option provides additional assurance should the WCA be uncomfortable in revealing the WCA IDs of senior competitors to the senior rankings team. The third option is much like the second, except it would use a modified SQL script to suppress competitors who have yet to provide their consent to the senior rankings team. The CSV extracts would only contain the details of competitors who have already provided their consent to the senior rankings team.

The 3x3x3 OH average rankings would look identical to those of option 2, despite smaller CSV extracts:

| **Rank** | **Person**                                                   | **Result** |
| -------- | ------------------------------------------------------------ | ---------- |
| 1        | Dave Campbell, Canada | 22.61      |
| 3        | Michael George, United Kingdom | 25.45      |
| 4        | Teller Coates, United States | 25.46      |
| 6        | Stefan Lidström, Sweden | 27.12      |

Note: Although the names and results for 2nd and 5th place are missing the rankings 1, 3, 4 and 6 are still accurate.

The implementation of option 3 would is more complex than options 1 and 2. In addition to suppressing competitors who have yet to provide their consent to the senior rankings team, rankings would have to be calculated within the SQL via window functions or temporary variables. Multiple extracts would also need to be produced by the SQL script; Over 40s, Over 50s, Over 60s, Over 70s, Over 80s.

This option has two obvious downsides:

1. The SQL script would need to run multiple similar queries to generate Over 40s, Over 50s, Over 60s, Over 70s and Over 80s rankings. This is not the end of the world but it would take several times longer to run; possible minutes rather than 10s of seconds.

2. Secondly and most significantly is that an updated SQL script would have to be provided to the WCA team every time a new competitor provides (or removes) their consent. It would make the consent process a lot more clunky and place more burden on everybody involved.

The benefit of option 3 is that it would ensure that additional senior competitors will NOT be disclosed to the senior rankings team. It is however the least favoured option due to the burdens it would place on everybody involved and any minor risks relating to options 1 and 2 can be mitigated through a [Legitimate Interests Assessment](https://ico.org.uk/for-organisations/guide-to-data-protection/guide-to-the-general-data-protection-regulation-gdpr/legitimate-interests/how-do-we-apply-legitimate-interests-in-practice/) (LIA) and suitable agreement, guaranteeing that WCA IDs of senior competitors will not be shared with anyone outside of the senior rankings team or used for purposes other than the senior rankings.

## Conclusion

All three options will allow improved senior rankings to be produced for the senior community, tackling the issue of missing competitors.

Implementing any one of the options will allow the senior rankings team to further meet the project goals:

1. Provide senior rankings - yes, ongoing
2. Provide accurate rankings - yes, vastly improved
3. Protect privacy - yes, ongoing

All three options can improve the existing reports by showing accurate rankings, whilst continuing to protect the privacy of individuals who have yet to provide their consent to the senior rankings team.

There is no need for any DOB information to be provided to the senior rankings team and nobody will ever appear in the senior rankings without providing their consent to the senior rankings team.

## Recommendations

Whilst none of the options in this proposal are intended to replace or supersede the proposal for [Official Senior Rankings](https://logiqx.github.io/wca-ipy/WCA_Proposal.html), they do offer an effective interim solution with minimal effort on the part of the WCA or the senior rankings team.

The necessary code already exists on GitHub so it could easily be scheduled to run on a daily basis. The required activities would be as follows:

1. Completion of the [Legitimate Interests Assessment](https://ico.org.uk/for-organisations/guide-to-data-protection/guide-to-the-general-data-protection-regulation-gdpr/legitimate-interests/how-do-we-apply-legitimate-interests-in-practice/) (LIA) - WCA Data Protection Committee (WDPC)
2. Scheduling the [SQL](https://github.com/Logiqx/wca-ipy/blob/master/sql/extract_senior_details.sql) extracts to run daily - WCA Results Team (WRT) / WCA Software Team (WST)
3. Creation of a machine on [AWS](https://aws.amazon.com/) to refresh the rankings daily - Senior Rankings Team

Finally, it is worth saying that it is still hoped that the earlier proposal for official senior rankings will one day become a reality.

