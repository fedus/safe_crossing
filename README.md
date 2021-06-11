
# Safe Crossing  
***Help make pedestrian crossings safer in Luxembourg-City***

Safe Crossing is an app that has been created out of the desire to make cities safer for pedestrians.

Specifically, many pedestrian crossings in Luxembourg-City (but actually, Luxembourg in general) are not compliant with the law. Article 166(h) of the "Code de la Route" ("Highway Code") says that parking spots are forbidden within 5 metres of a pedestrian crossing:

> Le stationnement des véhicules ou animaux est interdit: (h) sur les passages pour piétons et les passages pour cyclistes ainsi qu’à moins de 5 mètres de part et d’autre de ces passages ([link](http://legilux.public.lu/eli/etat/leg/code/route/20210515))

In reality, many parking spots, even officially marked ones, are right next to pedestrian crossings or well within the 5 metre limt.

Using Safe Crossing, users are presented with satellite images of pedestrian crossings in Luxembourg-City. The user can then vote and say whether the crossing is compliant with the law or not. There is also the possibility to say that the user can't say for sure what is applicable.

After collecting enough data (there are currently about 1600 pedestrian crossings of Luxembourg-City in the database), the results will be uploaded to the Open Data portal of the Luxembourg Government and an official letter will be addressed to the city council of the City of Luxembourg.

The data for pedestrian crossings comes from Open Street Maps. Satellite imagery sources vary (mostly Geoportail). The backend is implemented using Firebase Firestore and Firebase Cloud Functions (source code available in a separate repo).

Ideally, this app (and the backend) should be extended to cater for the whole of Luxembourg. Even better, this app could be used and adapted to similar regulations in countries around the world.
  
## Getting Started  
The Safe Crossing application is written in Flutter (Dart). At the time of writing (June 2021), the app runs on Android and iOS. In principle, the app also compiles for the Web. However, there are CORS issues for satellite imagery in the latter case, so a proxy would have to be used.
  
For help getting started with Flutter, view the  
[online documentation](https://flutter.dev/docs), which offers tutorials,  
samples, guidance on mobile development, and a full API reference.

Everything to get you going should be included in this repo, with the exception of Google Services settings (in specific, the API key to connect to your Firebase instance) and the necessary config to deploy the app to either Apple's AppStore or Google's Play Store.

To connect the app to your own Firebase instance, just follow the official Firebase documentation (or the FlutterFire documentation - FlutterFire is Firebase plugin for Flutter apps).

## Peculiarities with regards to Firebase
While Firebase has a relatively generous free tier, it is not a free service. In order to minimise reads / writes / deletes to and from Firebase, some more or less elegant workarounds have been implemented. This is specifically the case when it comes to counting records. Firebase does not have functionality to count documents in a collection, so one would have to iterate through each document and sum them up. Such an operation would constitute a read for each and every document in the collection. Now imagine several clients performing this ... it can easily get out of hand. To avoid this, the Firebase Cloud Functions keep some "manual" counters about certain things in meta documents. So keep this in mind when working on the project.
