//
//  BadgerPrefHandler.m
//  BadgerApp
//
//  Created by Snoolie Keffaber on 9/9/22.
//

#include "BadgerPrefHandler.h"

#define BADGER_BUILD_NUMBER 6
#define BADGER_CONFIG_FORMAT_VERSION 1
#define BADGER_MINIMUM_COMPATIBILITY_VERSION 6
#define BADGER_DISPLAY_VERSION_FOR_MINIMUM_COMPATIBILITY_VERSION "1.2.2"

NSString *preferencesDirectory = @"/var/mobile/Library/Badger/Prefs/BadgerPrefs.plist";

void badgerSaveUniversalPref(NSString *prefKey, id prefValue) {
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    [[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"DefaultConfig"]setObject:prefValue forKey:prefKey];
    [badgerPlist writeToFile:preferencesDirectory atomically:YES];
}
//prefApp is app's bundle ID
void badgerSaveAppPref(NSString *prefApp, NSString *prefKey, id prefValue) {
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    if (![[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]) {
        [[badgerPlist objectForKey:@"AppConfiguration"]setObject:[[NSMutableDictionary alloc]init] forKey:prefApp];
    }
    if (![[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"DefaultConfig"]) {
        [[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]setObject:[[NSMutableDictionary alloc]init] forKey:@"DefaultConfig"];
    }
    [[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"DefaultConfig"]setObject:prefValue forKey:prefKey];
    [badgerPlist writeToFile:preferencesDirectory atomically:YES];
}

void badgerSaveUniversalCountPref(long count, NSString *prefKey, id prefValue) {
    if (count <= 999999) {
        NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
        if ([[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]objectForKey:[NSString stringWithFormat:@"%ld",count]]) {
            [[[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]objectForKey:[NSString stringWithFormat:@"%ld",count]]setObject:prefValue forKey:prefKey];
        } else {
            if ([[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]) {
                [[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]setObject:[[NSMutableDictionary alloc]initWithObjectsAndKeys:prefValue,prefKey, nil] forKey:[NSString stringWithFormat:@"%ld",count]];
            } else {
                [[badgerPlist objectForKey:@"UniversalConfiguration"]setObject:[[NSMutableDictionary alloc]initWithObjectsAndKeys:[[NSMutableDictionary alloc]initWithObjectsAndKeys:prefValue,prefKey, nil],[NSString stringWithFormat:@"%ld",count],nil] forKey:@"CountSpecificConfigs"];
            }
        }
        [badgerPlist writeToFile:preferencesDirectory atomically:YES];
    }
}

void badgerSaveAppCountPref(long count, NSString *prefApp, NSString *prefKey, id prefValue) {
    if (count <= 999999) {
        NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
        if ([[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]objectForKey:[NSString stringWithFormat:@"%ld",count]]) {
            [[[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]objectForKey:[NSString stringWithFormat:@"%ld",count]]setObject:prefValue forKey:prefKey];
        } else {
            if (![[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]) {
                [[badgerPlist objectForKey:@"AppConfiguration"]setObject:[[NSMutableDictionary alloc]init] forKey:prefApp];
            }
            if ([[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]) {
                [[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]setObject:[[NSMutableDictionary alloc]initWithObjectsAndKeys:prefValue,prefKey, nil] forKey:[NSString stringWithFormat:@"%ld",count]];
            } else {
                [[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]setObject:[[NSMutableDictionary alloc]initWithObjectsAndKeys:[[NSMutableDictionary alloc]initWithObjectsAndKeys:prefValue,prefKey, nil],[NSString stringWithFormat:@"%ld",count],nil] forKey:@"CountSpecificConfigs"];
            }
        }
        [badgerPlist writeToFile:preferencesDirectory atomically:YES];
    }
}

void badgerRemoveUniversalPref(NSString *prefKey) {
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    [[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"DefaultConfig"]removeObjectForKey:prefKey];
    [badgerPlist writeToFile:preferencesDirectory atomically:YES];
}
//prefApp is app's bundle ID
void badgerRemoveAppPref(NSString *prefApp, NSString *prefKey) {
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    if ([[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"DefaultConfig"]objectForKey:prefKey]) {
        if ([[[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"DefaultConfig"]allKeys]count] <= 1) {
            //if the key we're removing is the only key, remove the app config altogether, speeds up the tweak a little
            if (![[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]) {
                [[badgerPlist objectForKey:@"AppConfiguration"]removeObjectForKey:prefApp];
            } else {
                [[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]removeObjectForKey:@"DefaultConfig"];
            }
        } else {
            [[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"DefaultConfig"]removeObjectForKey:prefKey];
        }
        [badgerPlist writeToFile:preferencesDirectory atomically:YES];
    } else if ([[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]) {
        if ([[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"DefaultConfig"]count] == 0) {
            //If ever called with no keys, cleanup ourselves
            if ([[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]) {
                [[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]removeObjectForKey:@"DefaultConfig"];
            } else {
                [[badgerPlist objectForKey:@"AppConfiguration"]removeObjectForKey:prefApp];
            }
            [badgerPlist writeToFile:preferencesDirectory atomically:YES];
        }
    }
}

void badgerRemoveUniversalCountPref(long count, NSString *prefKey) {
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    if ([[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]objectForKey:[NSString stringWithFormat:@"%ld",count]]) {
        if ([[[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]objectForKey:[NSString stringWithFormat:@"%ld",count]]count] == 1) {
            //since we're removing the only pref the count config has, might as well free the whole count config altogether
            if ([[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]count] <= 1) {
                [[badgerPlist objectForKey:@"UniversalConfiguration"]removeObjectForKey:@"CountSpecificConfigs"];
            } else {
                [[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]removeObjectForKey:[NSString stringWithFormat:@"%ld",count]];
            }
        } else {
            [[[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]objectForKey:[NSString stringWithFormat:@"%ld",count]]removeObjectForKey:prefKey];
        }
        [badgerPlist writeToFile:preferencesDirectory atomically:YES];
    }
}

void badgerRemoveAppCountPref(long count, NSString *prefApp, NSString *prefKey) {
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    if ([[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]objectForKey:[NSString stringWithFormat:@"%ld",count]]) {
        if ([[[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]objectForKey:[NSString stringWithFormat:@"%ld",count]]count] == 1) {
            //since we're removing the only pref the count config has, might as well free the whole count config altogether
            if ([[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]count] == 1) {
                if ([[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]count] == 1) {
                    [[badgerPlist objectForKey:@"AppConfiguration"]removeObjectForKey:prefApp];
                } else {
                    [[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]removeObjectForKey:@"CountSpecificConfigs"];
                }
            } else {
                [[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]removeObjectForKey:[NSString stringWithFormat:@"%ld",count]];
            }
        } else {
            [[[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]objectForKey:[NSString stringWithFormat:@"%ld",count]]removeObjectForKey:prefKey];
        }
        [badgerPlist writeToFile:preferencesDirectory atomically:YES];
    }
}

//this goes unused since the deb already comes prepackages with a blank pref file
void badgerSetUpPrefPlist(void){
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[[NSMutableDictionary alloc]initWithObjectsAndKeys:[[NSMutableDictionary alloc]init],@"DefaultConfig", nil],@"UniversalConfiguration",[[NSMutableDictionary alloc]init],@"AppConfiguration",@BADGER_CONFIG_FORMAT_VERSION,@"BadgerConfigFormatVersion",@BADGER_MINIMUM_COMPATIBILITY_VERSION,@"BadgerMinimumCompatibilityVersion",@BADGER_DISPLAY_VERSION_FOR_MINIMUM_COMPATIBILITY_VERSION,@"BadgerDiplayVersionForMinimumCompatibilityVersion",@YES,@"BadgerCheckCompatibility", nil];
    NSError* error=nil;
    NSPropertyListFormat format=NSPropertyListXMLFormat_v1_0; //NSPropertyListBinaryFormat_v1_0
    NSData* data =  [NSPropertyListSerialization dataWithPropertyList:badgerPlist format:format options:NSPropertyListImmutable error:&error];
    [data writeToFile:preferencesDirectory atomically:YES];
}

void badgerSetUpPrefPlistAtSpecificLocation(NSString *specifiedDirectory){
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[[NSMutableDictionary alloc]initWithObjectsAndKeys:[[NSMutableDictionary alloc]init],@"DefaultConfig", nil],@"UniversalConfiguration",[[NSMutableDictionary alloc]init],@"AppConfiguration",@BADGER_CONFIG_FORMAT_VERSION,@"BadgerConfigFormatVersion",@BADGER_MINIMUM_COMPATIBILITY_VERSION,@"BadgerMinimumCompatibilityVersion",@BADGER_DISPLAY_VERSION_FOR_MINIMUM_COMPATIBILITY_VERSION,@"BadgerDiplayVersionForMinimumCompatibilityVersion",@YES,@"BadgerCheckCompatibility", nil];
    NSError* error=nil;
    NSPropertyListFormat format=NSPropertyListXMLFormat_v1_0;
    NSData* data =  [NSPropertyListSerialization dataWithPropertyList:badgerPlist format:format options:NSPropertyListImmutable error:&error];
    [data writeToFile:specifiedDirectory atomically:YES];
}

id badgerRetriveUniversalPref(NSString *prefKey) {
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    if (!badgerPlist) {
        NSLog(@"BadgerApp ERROR: (badgerRetriveUniversalPref) Cannot find plist??");
        return NULL;
    }
    id universalConfiguration = badgerPlist[@"UniversalConfiguration"];
    if (!universalConfiguration) {
        //badgerPlist does not seem to have a UniversalConfiguration present - this should always??
        NSLog(@"BadgerApp ERROR: (badgerRetriveUniversalPref) No UniversalConfiguration present??");
        return NULL;
    }
    id universalDefaultConfig = universalConfiguration[@"DefaultConfig"];
    if (!universalDefaultConfig) {
        //UniversalConfiguration does not have DefaultConfig, return NULL
        return NULL;
    }
    return universalDefaultConfig[prefKey];
}
//prefApp is app's bundle ID
id badgerRetriveAppPref(NSString *prefApp, NSString *prefKey) {
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    if (!badgerPlist) {
        NSLog(@"BadgerApp ERROR: (badgerRetriveAppPref) Cannot find plist??");
        return NULL;
    }
    id appConfiguration = badgerPlist[@"AppConfiguration"];
    if (!appConfiguration) {
        //badgerPlist does not seem to have a AppConfiguration present
        return NULL;
    }
    id prefAppConfigs = appConfiguration[prefApp];
    if (!prefAppConfigs) {
        //app not in AppConfiguration, return NULL
        return NULL;
    }
    id prefAppDefaultConfig = prefAppConfigs[@"DefaultConfig"];
    if (!prefAppDefaultConfig) {
        //app does not have DefaultConfig, return NULL
        return NULL;
    }
    return prefAppDefaultConfig[prefKey];
}

id badgerRetriveUniversalCountPref(long count, NSString *prefKey) {
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    if (!badgerPlist) {
        NSLog(@"BadgerApp ERROR: (badgerRetriveUniversalCountPref) Cannot find plist??");
        return NULL;
    }
    id universalConfiguration = badgerPlist[@"UniversalConfiguration"];
    if (!universalConfiguration) {
        //badgerPlist does not seem to have a UniversalConfiguration present - this should always??
        NSLog(@"BadgerApp ERROR: (badgerRetriveUniversalCountPref) No UniversalConfiguration present??");
        return NULL;
    }
    id countSpecificConfigs = universalConfiguration[@"CountSpecificConfigs"];
    if (!countSpecificConfigs) {
        //count specific configs not in UniversalConfiguration, return NULL
        return NULL;
    }
    id countSpecificConfig = countSpecificConfigs[[NSString stringWithFormat:@"%ld",count]];
    if (!countSpecificConfig) {
        //UniversalConfiguration does not have this count config, return NULL
        return NULL;
    }
    return countSpecificConfig[prefKey];
}

id badgerRetriveAppCountPref(long count, NSString *prefApp, NSString *prefKey) {
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    if (!badgerPlist) {
        NSLog(@"BadgerApp ERROR: (badgerRetriveAppCountPref) Cannot find plist??");
        return NULL;
    }
    id appConfiguration = badgerPlist[@"AppConfiguration"];
    if (!appConfiguration) {
        //badgerPlist does not seem to have a AppConfiguration present
        return NULL;
    }
    id prefAppConfigs = appConfiguration[prefApp];
    if (!prefAppConfigs) {
        //app not in AppConfiguration, return NULL
        return NULL;
    }
    id prefAppCountSpecificConfigs = prefAppConfigs[@"CountSpecificConfigs"];
    if (!prefAppCountSpecificConfigs) {
        //count specific configs not in app's configs, return NULL
        return NULL;
    }
    id prefAppCountSpecificConfig = prefAppCountSpecificConfigs[[NSString stringWithFormat:@"%ld",count]];
    if (!prefAppCountSpecificConfig) {
        //app's CountSpecificConfigs does not have this count, return NULL
        return NULL;
    }
    return prefAppCountSpecificConfig[prefKey];
}

NSArray *badgerRetriveConfigsWithUniversalPref(NSString *prefKey) {
    NSMutableArray *configs = [[NSMutableArray alloc]init];
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    if (!badgerPlist) {
        NSLog(@"BadgerApp ERROR: (badgerRetriveConfigsWithUniversalPref) Cannot find plist??");
        return [[NSArray alloc]init];
    }
    id universalConfiguration = badgerPlist[@"UniversalConfiguration"];
    if (!universalConfiguration) {
        //badgerPlist does not seem to have a UniversalConfiguration present - this should always??
        NSLog(@"BadgerApp ERROR: (badgerRetriveConfigsWithUniversalPref) No UniversalConfiguration present??");
        return [[NSArray alloc]init];
    }
    id countSpecificConfigs = universalConfiguration[@"CountSpecificConfigs"];
    if (!countSpecificConfigs) {
        //count specific configs not in UniversalConfiguration, return NULL
        return [[NSArray alloc]init];
    }
    for (NSString *countConfig in countSpecificConfigs) {
        if ([[countSpecificConfigs objectForKey:countConfig]objectForKey:prefKey]) {
            [configs addObject:countConfig];
        }
    }
    return [[NSArray alloc]initWithArray:configs];
}

NSArray *badgerRetriveConfigsWithAppPref(NSString *prefApp, NSString *prefKey) {
    NSMutableArray *configs = [[NSMutableArray alloc]init];
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    if (!badgerPlist) {
        NSLog(@"BadgerApp ERROR: (badgerRetriveConfigsWithAppPref) Cannot find plist??");
        return [[NSArray alloc]init];
    }
    id appConfiguration = badgerPlist[@"AppConfiguration"];
    if (!appConfiguration) {
        //badgerPlist does not seem to have a AppConfiguration present
        return [[NSArray alloc]init];
    }
    id prefAppConfigs = appConfiguration[prefApp];
    if (!prefAppConfigs) {
        //app not in AppConfiguration, return NULL
        return [[NSArray alloc]init];
    }
    id prefAppCountSpecificConfigs = prefAppConfigs[@"CountSpecificConfigs"];
    if (!prefAppCountSpecificConfigs) {
        //count specific configs not in app's configs, return NULL
        return [[NSArray alloc]init];
    }
    for (NSString *countConfig in prefAppCountSpecificConfigs) {
        if ([[prefAppCountSpecificConfigs objectForKey:countConfig]objectForKey:prefKey]) {
            [configs addObject:countConfig];
        }
    }
    return [[NSArray alloc]initWithArray:configs];
}

BOOL badgerAddMinimumCompatibilityVersion(void) {
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    if (!badgerPlist) {
        NSLog(@"BadgerApp ERROR: (badgerAddMinimumCompatibilityVersion) Cannot find plist??");
        return NO;
    }
    [badgerPlist setObject:@BADGER_CONFIG_FORMAT_VERSION forKey:@"BadgerConfigFormatVersion"];
    [badgerPlist setObject:@BADGER_MINIMUM_COMPATIBILITY_VERSION forKey:@"BadgerMinimumCompatibilityVersion"];
    [badgerPlist setObject:@BADGER_DISPLAY_VERSION_FOR_MINIMUM_COMPATIBILITY_VERSION forKey:@"BadgerDiplayVersionForMinimumCompatibilityVersion"];
    [badgerPlist setObject:@YES forKey:@"BadgerCheckCompatibility"];
    NSError* error=nil;
    NSPropertyListFormat format=NSPropertyListXMLFormat_v1_0;
    NSData* data =  [NSPropertyListSerialization dataWithPropertyList:badgerPlist format:format options:NSPropertyListImmutable error:&error];
    [data writeToFile:preferencesDirectory atomically:YES];
    return YES; //operation was a success - return yes
}

//function for checking if the plist was set up before we included BadgerMinimumCompatibilityVersion
BOOL badgerDoesHaveCompatibilitySafetyFlags(void) {
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    if (!badgerPlist) {
        NSLog(@"BadgerApp ERROR: (badgerDoesHaveCompatibilitySafetyFlags) Cannot find plist??");
        return NO;
    }
    if (badgerPlist[@"BadgerCheckCompatibility"]) { //This key was added in Badger 1.2.2
        return YES;
    }
    if (badgerPlist[@"BadgerMinimumCompatibilityVersion"]) { //This key was added in Badger 1.2.2
        return YES;
    }
    if (badgerPlist[@"BadgerConfigFormatVersion"]) { //This key was added in Badger 1.2.2
        return YES;
    }
    if (badgerPlist[@"BadgerDiplayVersionForMinimumCompatibilityVersion"]) { //This key was added in Badger 1.2.2
        return YES;
    }
    //No compatibility safety keys could be found in badgerPlist - return NO
    return NO;
}

//ported from Paged
BOOL badgerIsCompatibleWithConfiguration(void) {
    NSMutableDictionary *pagedPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    if (!pagedPlist) {
        //if pagedPlist cannot be loaded
        return NO;
    }
    if (!pagedPlist[@"BadgerMinimumCompatibilityVersion"]) {
        //PagedMinimumCompatibilityVersion not present in pagedPlist
        return NO;
    }
    if ([pagedPlist[@"BadgerMinimumCompatibilityVersion"]integerValue] <= BADGER_BUILD_NUMBER) {
        return YES;
    }
    return NO;
}

//ported from Paged
NSString *badgerGetMinimumCompatibilityVersion(void) {
    NSMutableDictionary *pagedPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    if (!pagedPlist) {
        //if pagedPlist cannot be loaded
        return @"(NOCONFIG)";
    }
    NSString *ret = pagedPlist[@"BadgerDiplayVersionForMinimumCompatibilityVersion"];
    if (!ret) {
        //if PagedDiplayVersionForMinimumCompatibilityVersion cannot be loaded
        return @"(null)";
    }
    return ret;
}

//maybe ported from Paged i can't remember
id badgerGetMinimumCompatibilityBuildNumber(void) {
    NSMutableDictionary *pagedPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    if (!pagedPlist) {
        //if pagedPlist cannot be loaded
        return 0;
    }
    return pagedPlist[@"BadgerMinimumCompatibilityVersion"];
}

void badgerRemoveCurrentPref(long count, NSString *prefApp, NSString *prefKey) {
    if (prefApp) {
        if (count) {
            badgerRemoveAppCountPref(count,prefApp, prefKey);
        } else {
            badgerRemoveAppPref(prefApp, prefKey);
        }
    } else {
        if (count) {
            badgerRemoveUniversalCountPref(count,prefKey);
        } else {
            badgerRemoveUniversalPref(prefKey);
        }
    }
}

void badgerSaveCurrentPref(long count, NSString *prefApp, NSString *prefKey, id prefValue) {
    if (prefApp) {
        if (count) {
            badgerSaveAppCountPref(count,prefApp, prefKey, prefValue);
        } else {
            badgerSaveAppPref(prefApp, prefKey, prefValue);
        }
    } else {
        if (count) {
            badgerSaveUniversalCountPref(count, prefKey, prefValue);
        } else {
            badgerSaveUniversalPref(prefKey, prefValue);
        }
    }
}

id badgerRetriveCurrentPref(long count, NSString *prefApp, NSString *prefKey) {
    if (count) {
        if (prefApp) {
            return badgerRetriveAppCountPref(count, prefApp, prefKey);
        } else {
            return badgerRetriveUniversalCountPref(count, prefKey);
        }
    } else {
        if (prefApp) {
            return badgerRetriveAppPref(prefApp, prefKey);
        } else {
            return badgerRetriveUniversalPref(prefKey);
        }
    }
}
