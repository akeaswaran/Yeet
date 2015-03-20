# Yeet
A simple one-tap messaging app based on modern teenage slang and Yo.

### Backend Setup
* Three main objects: User, Friend, and Blocked
* User attributes: username, password, unique object ID (usually assigned by backend)
* Friend attributes: unique object ID, user (reference to the user who is taking this action), friend (reference to user affected by this action)
* Blocked attributes: unique object ID, user (reference to the user who is taking this action), blocked (reference to user affected by this action)

### Features/Notes
* Simple one-tap messaging, like [Yo](http://www.justyo.co).
* Built on the safe and secure [Parse.com](http://parse.com) cloud platform and Apple's own [CloudKit](https://developer.apple.com/icloud/documentation/cloudkit-storage/).
* Really barebones; not intended for release, just for practice.

### Credits
* CloudKit functions adapted from [JagCesar's CloudKit version of Yo.](https://github.com/JagCesar/CloudKit-YO).
* [JFMinimalNotifications](https://github.com/atljeremy/JFMinimalNotifications)
* [GMDCircleLoader](https://github.com/gabemdev/GMDCircleLoader)
* [Colours](https://github.com/bennyguitar/Colours)
