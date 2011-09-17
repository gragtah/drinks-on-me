Drinks On Me
============

by Venmo


What is it
----------

Drinks On Me is a mobile app that allows Foursquare users to pay their Foursquare friends or other people checked in to your location. Payments are managed through the Venmo iOS SDK. The code to Drinks On Me is open-sourced and serves as an example of how to combine Foursquare and Venmo on a mobile app.

How to use DrinksOnMe
---------------------

First, download the DrinksOnMe project. Open the project in Xcode and you'll see that it doesn't compile. You need to change the file named AppConstants.h.sample. Rename it to AppConstants.h and include your Foursquare app credentials and your Venmo app credentials.

To get your Venmo app credentials, check out https://venmo.com/account/new/app/new . To get your app registered with Foursquare, visit [developer.foursquare.com][1] for more details.

Input the credentials in AppConstants.h. Build DrinksOnMe and run it.

As a reference, you can check out https://github.com/venmo/venmo-ios-sdk to see how to download and use the Venmo SDK.


  [1]: https://developer.foursquare.com/