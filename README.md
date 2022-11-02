# BadgerPrefs
This is how Badger handles prefs, how BadgerApp and the Badger tweak communicate.
While Badger is kept closed source at the moment, config management is open source since bugs/speed here will likely be most impactful.

Buy Badger on Havoc (https://havoc.app) for $0.99.

## /var/mobile/Library/Badger/
This directory is where BadgerApp stores data for the Badger tweak. `/var/mobile/Library/Badger/Prefs/BadgerPrefs.plist` is the majority of how it communicates, `/var/mobile/Library/Badger/BadgeImages/` is the directory that the app stores custom images from user. This readme is going to focus on `/var/mobile/Library/Badger/Prefs/BadgerPrefs.plist`.

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
Key that contains the count specific configs for AppConfiguration -> (app bundle ID), sorted least to greatest.

## Configuration Priority
If the most prioritized config doesn't have a key that a lower config does, then Badger may merge from the lower prioritized config. (EXCEPTION TO THIS: AppConfiguration DefaultConfig does not inherit from UniversalConfiguration CountSpecificConfigs). Remember, this is how Badger should see configs, most prioritized to least prioritized:

- AppConfiguration -> (app bundle id) -> CountSpecificConfigs:
- AppConfiguration -> (app bundle id) -> DefaultConfig:
- UniversalConfiguration -> CountSpecificConfigs:
- UniversalConfiguration -> DefaultConfig:

## Pre-Merging Prefs in %ctor
Since it may be bad for performance to cycle through and manage inheritance each time a badge is hooked, Badger takes care of this and merges the configurations in its %ctor, so Badger can perform better.

## Should I change `/var/mobile/Library/Badger/` by hand without the app?
Short answer: **NO!**


BadgerApp is a much more safe method of changing Badger configs, and the intended way. Use Badger's app. 
