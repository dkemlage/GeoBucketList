## What is does
The **GeoBucketList** is a mobile application to track your geography 'bucket list' - where you have been and where you want to go. 

## Inspiration
A **bucket list** is a number of experiences or achievements that a person hopes to have or accomplish during their lifetime. At Esri, we love **geography** (aka. 'The Science of Where'). Our `HackTheMap` team thought it would be great union these concepts (**Geography** and a **Bucket List**) together and create an application for it. The **GeoBucketList** becomes an electronic journal (via your mobile device) to record the experiences of places that you have been.   

## What it does
You use Esri tools like [ArcGIS Desktop](https://desktop.arcgis.com/en/) or [ArcGIS Pro](https://www.esri.com/en-us/arcgis/products/arcgis-pro/resources) to author a geographic layers of places that you want to visit. Each layer becomes a geographic 'bucket list' for places you want to see in your lifetime. They can be things like:
- States
- Counties
- National Parks
- Museums
- Major League Ballparks
- Tasty Food Eateries
- (whatever places you really want to visit)

The geographic 'bucket list' layer is then uploaded to [ArcOnline](https://www.esri.com/en-us/arcgis/products/arcgis-online/overview).

When you open the **GeoBucketList** application on your mobile device (i.e. Android or iPhone) you are presented with an option to select which geographic 'bucket list' layers you want to view that are available via your ArcGIS Online account.

Initially, the geographies in the geographic 'bucket list' layer are masked (kind of like a scratchers game) to obscure the basemap layer below. As you visit the location of each geography, you click the button to mark that you have now seen that place. You are will be presented with a dialog to upload a picture on your device that demonstrates that you were there and the date of your visit.

After you have recorded your geographic 'bucket list' journal entry, you can go back later and click on any geography to see when you were there, the exact coordinate location, and photographic memory you captured.  

## How we built it
The mobile application was built using Esri's [AppStudio for ArcGIS](https://appstudio.arcgis.com). It was build using the QML and JavaScript languages. The geographic 'bucket list' histories are stored as JSON on the device. The example geographic 'bucket list' layers were available on ArcGIS Online.

## Challenges we ran into
Hackathon deadlines are tight (typically about 48 to 72 hours). It is challenging to create a fully functional applications, with clean design and workflows, and useful documentation in a short period of time.

In our case we hit a potential bug or usability issue in the 'Unique Value Renderer' that will require more research.

## Accomplishments that we're proud of
We were actually able to create a fully functional application in the time allotted for the Hack-a-Thon!

## What we learned
The Hack-the-Map 4 hackathon was a fun. This was the second year our 2 person team worked together. This year we switch roles from last year on who did the coding of the app (Brandon this year) and who did the design/presentation (Don this year)

## What's next for GeoBucketList
These are ideas we came up with for further development/refinement:

- Our current geographic 'bucket list' layers only supports polygons. We would like to explore having the app work with point and line features.
- Be able to find the next nearest 'bucket list' geography from where you currently are.
- Be able to rank visually (perhaps via labeling) priority place in the bucket list that you want to visit.
- Be able to add multiple pictures per bucket list journal entry.
- Add audio recordings as part of journal entry.
