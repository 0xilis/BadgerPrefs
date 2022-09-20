# BadgerPrefs
This is how Badger handles prefs, how BadgerApp and the Badger tweak communicate.
While Badger is kept closed source at the moment, config management is open source since bugs/speed here will likely be most impactful.

## /var/Badger/
This directory is where BadgerApp stores data for the Badger tweak. `/var/Badger/Prefs/BadgerPrefs.plist` is the majority of how it communicates, `/var/Badger/BadgeImages/` is the directory that the app stores custom images from user, and `/var/Badger/DefaultBackground/` has `BadgeRectangle.png` (if the user has no custom image set but a shape set, it uses this image then applies the shape config), as well as `BadgeEllipse.png`, which while was previously used by Badger while the first version was still being developed, it is no longer used by Badger since a rewrite, but still kept because not really any point of deleting it. This readme is going to focus on `/var/Badger/Prefs/BadgerPrefs.plist`.

## UniversalConfiguration
Key that contains the configuration to apply universally for all apps (unless a app has a AppConfiguration that overrides it).

## UniversalConfiguration -> DefaultConfig
Key that contains the configuration to apply universally for all apps (unless a app has a AppConfiguration that overrides it), and universally no matter the badge count unless overridden by a countconfig for the badge's current count.

## UniversalConfiguration -> CountSpecificConfigs
Key that contains the count specific configs for UniversalConfiguration, sorted least to greatest.

## AppConfiguration -> (app bundle ID)
Key that contains the configuration to apply for the app with the bundle id.

## AppConfiguration -> (app bundle ID) -> DefaultConfig
Key that contains the configuration to apply for the app with the bundle id, and universally no matter the badge count unless overridden by a countconfig for the badge's current count.

## AppConfiguration -> (app bundle ID) -> CountSpecificConfigs
Key that contains the count specific configs for AppConfiguration -> (app bundle ID), sorted least to greatest. The current version of Badger does not ship with a version of BadgerApp with these, but may later.

## Configuration Priority
If the most prioritized config doesn't have a key that a lower config does, then Badger may merge from the lower prioritized config. (EXCEPTION TO THIS: AppConfiguration DefaultConfig does not inherit from UniversalConfiguration CountSpecificConfigs). Remember, this is how Badger should see configs, most prioritized to least prioritized:

- ~~AppConfiguration -> (app bundle id) -> CountSpecificConfigs:~~ (Currently not in use)
- AppConfiguration -> (app bundle id) -> DefaultConfig:
- UniversalConfiguration -> CountSpecificConfigs:
- UniversalConfiguration -> DefaultConfig:

## Should I change `/var/Badger/Prefs/BadgerPrefs.plist` by hand without the app?
Short answer: **NO!**


BadgerApp is a much more safe method of changing Badger configs, and the intended way. Use Badger's app. 
