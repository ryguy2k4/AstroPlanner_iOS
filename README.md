# Astrophotography Planner
## Overview

Astrophotography Planner makes it easy for astrophotographers to filter through a catalog of deep sky targets and also provides
a daily report that uses an algorithm that determines the best targets.  Each target has a calculated visibility score that measures
what percentage of the night the target is visible for and a season score that measures how close the target is to its opposition
from the sun. The algorithm makes use of both of these scores and information about the moon in order to present the user a list
of possible targets to image. Information can be queried for any date and location.

View the app on the [App Store](https://apps.apple.com/us/app/astrophotography-planner/id1661476234).

## Timeline
I conceived the idea for this app in mid-2022 and began working on it in November 2022. From November 2022 through the end of the year,
I taught myself how to program in Swift and use the SwiftUI framework to bring my vision to life. On January 8, 2023 I published a video on
Youtube called ["I Created an App for Astrophotography Planning"](https://www.youtube.com/watch?v=TEC2_SUVBvc). I had a public beta
 that I was trying to get people to join; the app was ready for some initial testing.

I continued adding features, making optimizations, and adjusting it to my vision over the next few months. I kept releasing updates to the
public beta through July. Version 1.0 was released on the app store on July 13, 2023. On October 25, 2023, I released a second YouTube
video announcing the release of the app, called ["My Astrophotography Planning App"](https://www.youtube.com/watch?v=U2BWvj2M7jY).

Since then, I've periodically released additional updates. It is currently on version 1.6 (as of 2/20/25).

## Features

### Catalog
The catalog contains a list of 266 deep sky objects. The list can be searched, or filtered by type, size, catalog, constellation, magnitude, visibility
score, and/or season score. Each target has lots of information associated that can be viewed in its detail view. It displays an image (if present), 
coordinates, size, a graph of visibility over the course of the night, and a graph of season score over the course of the year. Each target also has a
brief description obtained from wikipedia.

### Daily Report
The daily report shows the top five targets of any kind. Below that the top ten targets for three different categories are shown (nebulae, galaxies,
and star clusters). The user determines the date, or more specfically a portion of the night (termed viewing interval), the location, and optionally 
can specify what equipment they have to determine the appropriate field of view. The algorithm takes all these factors into account and uses both
season score and visibility score to determine the best targets.

### Future Work

#### Widgets 
I've experimented with making widgets, but they are still in development.

#### Planetary
I would like to add calculations and suggestions for planetary targets.

## Related Projects

### Mac Desktop Version
I have created a separate UI adapted to desktop, but it is incomplete and unpublished.

### Android Version
During the summer of 2024, I began developing an Android version of the app. It is currently in development and I am preparing it for a
public beta release.

### Journal App
I had another idea for an app that would function as a journal for astrophotography. My vision is that it would act as a data repository for
information about individual imaging sessions and projects. It would be fed log files and image metadata to create the journal entry. I've
spent a little time developing this idea as a desktop app on Mac. I determined that it should be independent to Astrophotography Planner,
but they would interface with each other a little. I have not yet had time to put enough thought and effort into developing this app, but it
is something I would like to see happen eventually.
