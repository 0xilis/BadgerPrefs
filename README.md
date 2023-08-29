# BadgerPrefs
This is how Badger handles prefs, how BadgerApp and the Badger tweak communicate.
While Badger is kept closed source at the moment, config management is open source since bugs/speed here will likely be most impactful.

~~Buy Badger on Havoc (https://havoc.app) for $0.99.~~ (Badger has temporarily been made free).

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

# Compatibility Flags

Brand new to Badger 1.2.2 / Badger Build 6 are compatibility safety flags. These include:

* `BadgerDiplayVersionForMinimumCompatibilityVersion` - String. The display version of Badger that is the minimum compatible, ex if build 6 is min, display this as 1.2.2.
* `BadgerMinimumCompatibilityVersion` - Number. The minimum build of badger that is compatible with the config file.
* `BadgerCheckCompatibility` - Boolean. Defaults to `YES`. If set to `NO`, Badger will not check compatibility flags.
* `BadgerConfigFormatVersion` - Number. The current version of the config format. Since this was added in 1.2.2, Badger 1.2.2 defaults this to `1`.

### Important Note

Compatibility flags are new as a feature of Badger 1.2.2 / Build 6. (I was making Paged, a future tweak in dev, but implemented this and decided to implement it in Badger as well). When Paged eventually releases, expect behavior of compatibility flags to be similar to Badger. Since these are new to Badger 1.2.2 / Build 6 however instead of being implemented from the start - be aware that 1.2.1-1 and earlier builds of Badger will *NOT* check compatibility.

### Migrating from pre-compatibility flags

Badger 1.2.2 / Build 6 now auto-includes the compatibility flags in the BadgerPrefs.plist it creates. However, to handle cases where the user already has a `BadgerPrefs.plist` and is upgrading from a older version of Badger without compatibility flags, BadgerApp, when loading, checks if `BadgerDiplayVersionForMinimumCompatibilityVersion`/`BadgerMinimumCompatibilityVersion`/`BadgerCheckCompatibility`/`BadgerConfigFormatVersion` exist. If none of them do, it adds them all. If it fails to add them, it displays an alert.

### Checking compatibility

Badger 1.2.2, if `BadgerCheckCompatibility` is set to YES, will check if `BadgerMinimumCompatibilityVersion` is less or equal to the current Badger build number. If so, it displays an alert telling to upgrade to `BadgerMinimumCompatibilityVersion` or higher. It also gives the option to either attempt to continue normally anyway, or reset the configuration file.
