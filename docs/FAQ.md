![alt text](img/logo.jpg "logo")
## Frequently Asked Questions (FAQ)

### General

#### Why was this project created?

Prior to my first competition, I was curious about what kind of times the over 40s were achieving in competition. I was quite active on the Speedsolving.com forum so I created a [thread](https://www.speedsolving.com/threads/how-fast-are-the-over-40s-in-competitions.54128/) listing the results of the people that I knew personally or who were well known in the community.

The original list of official results only contained 11 seniors but the list was up to 23 names within a week. Since its creation the senior rankings have continued to grow and now have almost 500 seniors listed in Nov 2019. It was intended to be a one-off activity but has subsequently evolved into an automated process.

####  What results qualify for the senior rankings?

Only official results achieved after turning 40 are eligible for the over 40s rankings. The same principle applies to the over 50s, 60s, 70s, 80s rankings.

It is worth noting that results after turning 50 will apply to multiple age categories. For example, official results of a 68 year old competitor will be eligible for the over 40s, over 50s and over 60s rankings.

#### How often is this website updated?

The senior rankings are updated daily using the WCA [results export](https://www.worldcubeassociation.org/results/misc/export.html) which is published at around 0400 GMT. A daily batch job runs at 0410 GMT which downloads the latest WCA database export and refreshes the senior rankings.

The "[Future Competitions](Future_Competitions.html)" page is updated every 3 hours - 0000 GMT, 0300 GMT, 0600 GMT, etc. This ensures that any registration changes are reflected promptly without the process being overly excessive.

#### How many seniors have competed?

As of Nov 2019 the number of people who have competed after turning 40 is likely to be around 2,000. This is based on some historical numbers that are known to be accurate:

- 3x3x3 singles as of February 2019 = 1,531 seniors
- 3x3x3 singles as of August 2019 = 1,836 seniors

#### How do I get my name added?

I will require your WCA ID and DOB. If you are a member of Speedsolving.com then please provide your nickname as well.

Instructions for getting your name added to this website are on the [front page](README.md) of the website.

#### What is your data privacy policy?

The data privacy policy is described in the [Privacy Notice](Privacy_Notice.md).

In a nutshell, I am committed to keeping your DOB well protected and it will never be published publicly.



### Partial Rankings

#### How complete are the partial rankings?

I did some analysis in August 2019 which showed that coverage is better at the top of the rankings:

>**Percentage coverage for 3x3x3**  
>90% of sub-15 | 58% of sub-20 | 53% of sub-25 | 48% of sub-30 | 42% of sub-45 | 37% of sub-1:00  
>
>**3x3x3 variations have greater coverage**  
>OH: 75% of sub-0:40 | 3BLD: 75% of sub-4:00 | Feet: 90% of sub-4:00 | FMC: 90% of sub-40  
>
>**Big cubes have even greater coverage**  
>4x4: 75% of sub-1:30 | 5x5: 85% of sub-3:00 | 6x6: 90% of sub-6:00 | 7x7: 95% of sub-9:00



### Indicative Rankings

#### What are the indicative rankings?

The [Indicate Rankings](Indicative_Rankings.html) are the best possible indication that I can provide of your “real” world ranking. Non-contiguous ranks are due to the number of unlisted seniors. The indicative rankings were created using official data from the WCA database and basic modelling techniques to place the unknown seniors.

#### What data do they use?

I initially used summarised data from back in Feb 2019 to determine where gaps exist in the senior rankings. Since the Feb 2019 data is now somewhat out of date, I've had to build simple predictive models which consider the growth of the senior community and improvement in times to predict the distributions of senior results.

####  Why are there no singles?

I only had data for official averages and I did not have any data for official singles. I did consider building predictive models for official singles but since singles can be so luck dependant, I wasn't happy with the accuracy of such an approach. I have decided not to do indicative rankings for singles unless I have reliable data to base them upon.

#### Will indicative rankings improve in the future?

My hope / intention is to get up-to-date information from the WCA which allows me to create indicative rankings for all of the senior categories (40, 50, 60, 70, 80), covering both averages and singles.

I've put in a lot of the groundwork for this to be possible in the future (without the need for any predictive modelling) but my approach is yet to be agreed with the WCA.



### Percentile Rankings

#### What are the percentile rankings?

The percentile rankings were created prior to the "[Indicate Rankings](Indicative_Rankings.html)" to give an idea of the kind of times being obtained by the senior cubing community.

They are obviously a statistical view of the official results by the senior cubing community and offer a different type of insight into the senior cubing community.

#### What data do they use?

I initially used summarised data from back in Feb 2019 to determine where gaps exist in the senior rankings. Since the Feb 2019 data is now somewhat out of date, I've had to build simple predictive models which consider the growth of the senior community and improvement in times to predict the distributions of senior results.

#### Why are there no singles?

I only had data for official averages and I did not have any data for official singles. I did consider building predictive models for official singles but since singles can be so luck dependant, I wasn't happy with the accuracy of such an approach. I have decided not to do indicative rankings for singles unless I have reliable data to base them upon.



### Future Competitions

The "[Future Competitions](Future_Competitions.html)" page is updated throughout the day using the [WCA API](https://github.com/thewca/worldcubeassociation.org/wiki) and a number of additional websites that are used for competition registration.

It retrieves registration data from [worldcubeassociation.org](https://www.worldcubeassociation.org/competitions), [cubingchina.com](https://cubingchina.com/competition), [cubing-tw.net](https://cubing-tw.net/event/), [zawody4event.pl](https://zawody4event.pl/#competitions), [speedcubing.pl](https://www.speedcubing.pl/), [speedcubing.nz](https://www.speedcubing.nz/), [canadiancubing.com](http://www.canadiancubing.com/Events) and [cubecomp.de](https://cubecomp.de/)

