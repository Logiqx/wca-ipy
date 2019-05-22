# Senior Rankings

## Introduction

The [Unofficial Senior Rankings](https://logiqx.github.io/wca-ipy/) have been evolving since 2015 and have been rapidly growing in popularity over the past few months. The main artefact of the project is known as the [Partial Over 40s Rankings](https://logiqx.github.io/wca-ipy/Partial_Rankings.html) and currently includes around 200 competitors. The current completeness of the Over 40s Rankings can be summarised as follows:

>**Percentage coverage for 3x3x3**  
>90% of sub-15 | 50% of sub-20 | 43% of sub-25 | 34% of sub-30 | 25% of sub-45 | 21% of sub-1:00  
>
>**3x3x3 variations have greater coverage**  
>OH: 70% of sub-0:40 | 3BLD: 80% of sub-4:00 | Feet: 100% of sub-4:00 | FMC: 100% of sub-40  
>
>**Big cubes have even greater coverage**  
>4x4: 75% of sub-1:30 | 5x5: 85% of sub-3:00 | 6x6: 95% of sub-6:00 | 7x7: 100% of sub-9:00

Nobody has ever declined to be included in the senior rankings. Nobody has ever complained and nobody has ever asked to be removed.

Feedback has always been very positive, appreciative and many of the senior competitors are wildly enthusiastic about the senior rankings!


## Project Goals

The project has three main goals:

1. We wish to provide senior rankings to the community - Over 40s, Over 50s, Over 60s, etc.
2. We wish to provide actual rankings, regardless of how many names are actually listed.
3. We wish to protect the privacy of competitors who have not yet provided their consent.

The  project satisfies the first goal reasonably well due to the coverage that we have for the faster competitors. It falls short on the second goal due to the number of competitors that are missing from the rankings. The project team has always taken privacy very seriously and recently added a [Privacy Statement](http://logiqx.github.io/wca-ipy/Privacy_Notice.html).

We wish to tackle the second goal by showing actual rankings despite there being some competitors missing from the rankings. For example the [3x3x3 OH](http://logiqx.github.io/wca-ipy/Partial_Rankings.html#averages) average rankings should show; 1st Dave Campbell 22.61, 3rd Michael George 25.45, 4th Teller Coates 25.46, 6th Stefan Lidström 27.12. The names and results for 2nd and 4th should remain hidden but the fact that they exist made clear by their absence from the list of names and results.


## Improvements

Two options are being proposed to tackle the second project goal; i.e. actual rankings.

Neither option requires the WCA to provide DOB information to the senior rankings team. Both options simply require SQL extracts to be run on the WCA server from which the senior rankings team can produce the various reports. The CSV extracts would be identical to those currently used to produce the [Partial Over 40s Rankings](http://logiqx.github.io/wca-ipy/Partial_Rankings.html).

* [known_senior_details.csv](https://github.com/Logiqx/wca-ipy/blob/master/data/public/extract/known_senior_details.csv) - WCA ID, name and age category when they last competed
* [known_senior_averages.csv](https://github.com/Logiqx/wca-ipy/blob/master/data/public/extract/known_senior_averages.csv) - Event, WCA ID, PR average and age category
* [known_senior_singles.csv](https://github.com/Logiqx/wca-ipy/blob/master/data/public/extract/known_senior_singles.csv) - Event, WCA ID, PR single and age category

Note: Event + WCA ID will often appear multiple times; once for each applicable age category. The CSV extracts are used to generate the partial rankings for the Over 40s, Over 50s, Over 60s, etc.

### Option 1

The SQL that produces the CSV files is hosted on GitHub - [extract_senior_details.sql](https://github.com/Logiqx/wca-ipy/blob/master/sql/extract_senior_details.sql)

If this script is run against the WCA database, existing project code can be used to produce improved rankings, suppressing competitors who are yet to provide their consent. The reports will therefore look near-identical to the existing [partial rankings](http://logiqx.github.io/wca-ipy/Partial_Rankings.html) but the rankings themselves will be accurate, tackling the second goal of the project.

For example the [3x3x3 OH](http://logiqx.github.io/wca-ipy/Partial_Rankings.html#averages) average rankings would show; 1st Dave Campbell 22.61, 3rd Michael George 25.45, 4th Teller Coates 25.46, 6th Stefan Lidström 27.12. The names and results for 2nd and 4th would remain hidden but the fact that they exist made clear by their absence from the list of names and results.

This is the preferred option in this proposal, based on a suitable agreement being signed, guaranteeing that WCA IDs of senior competitors will not be shared with anyone or used for purposes other than the senior rankings.

Note: The CSV extracts will NOT include DOB information, only age categories 40+, 50+, 60+, etc.

### Option 2

The second option is much the same as the first but it would use a modified SQL script to suppress the people who have yet to provide their consent to the senior rankings team. The rankings would be calculated within the SQL itself by using window functions or temporary variables. Multiple extracts would have to be generated by the SQL script; Over 40s, Over 50s, Over 60s, etc.

This second option has two downsides:

1. Firstly, the SQL script to generate Over 40s, Over 50s ... Over 80s would need to run multiple queries and combine the results. This is not the end of the world but it would take several times longer to run; possible minutes rather than 10s of seconds.

2. Secondly and most significantly is that an updated SQL script would need to be provided to the WCA team every time a new competitor provides (or removes) their consent. It would make the consent process a lot more clunky and place more burden on everybody involved.

Due to the downsides described the first option is recommended over the second option. This is based on a suitable agreement being signed, guaranteeing that WCA IDs of senior competitors will not be shared with anyone or used for purposes other than the senior rankings.

### Legal Basis

Article 6(1)(f) of GDPR provides a lawful basis for processing where:

>“processing is necessary for the purposes of the legitimate interests pursued by the controller or by a third party except where such interests are overridden by the interests or fundamental rights and freedoms of the data subject which require protection of personal data, in particular where the data subject is a child.”

An overview of legitimate interests is available on the [Information Commissioner's Office](https://ico.org.uk/for-organisations/guide-to-data-protection/guide-to-the-general-data-protection-regulation-gdpr/lawful-basis-for-processing/legitimate-interests/) (ICO) website.

## Summary

Both options described in this document allow for improved senior rankings to be produced, tackling all of the project goals:

1. Provide senior rankings - YES
2. Provide actual rankings - YES
3. Protect privacy - YES

There is no need to receive any DOB information in order to produce improved senior rankings and nobody will ever appear in the senior rankings without providing their consent. This can be guaranteed through the signing of an agreement between the WCA and the senior rankings team.

Both options improve upon the existing [partial rankings](http://logiqx.github.io/wca-ipy/Partial_Rankings.html) whilst continuing to exclude competitors who have yet to provide their consent to the senior rankings team.

The improved senior rankings will also be consistent with the proposal for [official senior rankings](https://logiqx.github.io/wca-ipy/WCA_Proposal.html) on the WCA website, submitted in February 2019.
