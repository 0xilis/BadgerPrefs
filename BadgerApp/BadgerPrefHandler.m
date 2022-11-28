//
//  BadgerPrefHandler.m
//  BadgerApp
//
//  Created by Snoolie Keffaber on 9/9/22.
//

#include "BadgerPrefHandler.h"

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
        if ([[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]) {
            [[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]setObject:[[[[badgerPlist objectForKey:@"AppConfiguration"] objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]objectForKey:countConfigStr] forKey:countConfigStr];
        } else {
            [[badgerPlist objectForKey:@"UniversalConfiguration"]setObject:[[NSMutableDictionary alloc]initWithObjectsAndKeys:[[NSMutableDictionary alloc]initWithObjectsAndKeys:prefValue,prefKey, nil],[NSString stringWithFormat:@"%ld",count],nil] forKey:@"CountSpecificConfigs"];
        }
        [badgerPlist writeToFile:preferencesDirectory atomically:YES];
    }
}

void badgerSaveAppCountPref(long count, NSString *prefApp, NSString *prefKey, id prefValue) {
    if (count <= 999999) {
        NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
        if ([[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]) {
            [[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]setObject:[[[[badgerPlist objectForKey:@"AppConfiguration"] objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]objectForKey:countConfigStr] forKey:countConfigStr];
        } else {
            if (![[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]) {
                [[badgerPlist objectForKey:@"AppConfiguration"]setObject:[[NSMutableDictionary alloc]init] forKey:prefApp];
            }
            [[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]setObject:[[NSMutableDictionary alloc]initWithObjectsAndKeys:[[NSMutableDictionary alloc]initWithObjectsAndKeys:prefValue,prefKey, nil],[NSString stringWithFormat:@"%ld",count],nil] forKey:@"CountSpecificConfigs"];
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
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[[NSMutableDictionary alloc]initWithObjectsAndKeys:[[NSMutableDictionary alloc]init],@"DefaultConfig", nil],@"UniversalConfiguration",[[NSMutableDictionary alloc]init],@"AppConfiguration", nil];
    NSError* error=nil;
    NSPropertyListFormat format=NSPropertyListXMLFormat_v1_0;
    NSData* data =  [NSPropertyListSerialization dataWithPropertyList:badgerPlist format:format options:NSPropertyListImmutable error:&error];
    [data writeToFile:preferencesDirectory atomically:YES];
}

void badgerSetUpPrefPlistAtSpecificLocation(NSString *specifiedDirectory){
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[[NSMutableDictionary alloc]initWithObjectsAndKeys:[[NSMutableDictionary alloc]init],@"DefaultConfig", nil],@"UniversalConfiguration",[[NSMutableDictionary alloc]init],@"AppConfiguration", nil];
    NSError* error=nil;
    NSPropertyListFormat format=NSPropertyListXMLFormat_v1_0;
    NSData* data =  [NSPropertyListSerialization dataWithPropertyList:badgerPlist format:format options:NSPropertyListImmutable error:&error];
    [data writeToFile:specifiedDirectory atomically:YES];
}

id badgerRetriveUniversalPref(NSString *prefKey) {
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    if ([[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"DefaultConfig"]objectForKey:prefKey]) {
        return [[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"DefaultConfig"]objectForKey:prefKey];
    }
    return NULL;
}
//prefApp is app's bundle ID
id badgerRetriveAppPref(NSString *prefApp, NSString *prefKey) {
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    if ([[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"DefaultConfig"]objectForKey:prefKey]) {
        return [[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"DefaultConfig"]objectForKey:prefKey];
    }
    return NULL;
}

id badgerRetriveUniversalCountPref(long count, NSString *prefKey) {
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    if ([[[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]objectForKey:[NSString stringWithFormat:@"%ld",count]]objectForKey:prefKey]) {
        return [[[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]objectForKey:[NSString stringWithFormat:@"%ld",count]]objectForKey:prefKey];
    }
    return NULL;
}

id badgerRetriveAppCountPref(long count, NSString *prefApp, NSString *prefKey) {
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    if ([[[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]objectForKey:[NSString stringWithFormat:@"%ld",count]]objectForKey:prefKey]) {
        return [[[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]objectForKey:[NSString stringWithFormat:@"%ld",count]]objectForKey:prefKey];
    }
    return NULL;
}

NSArray *badgerRetriveConfigsWithUniversalPref(NSString *prefKey) {
    NSMutableArray *configs = [[NSMutableArray alloc]init];
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    for (NSString *countConfig in [[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]allKeys]) {
        if ([[[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]objectForKey:countConfig]objectForKey:prefKey]) {
            [configs addObject:countConfig];
        }
    }
    return [[NSArray alloc]initWithArray:configs];
}

NSArray *badgerRetriveConfigsWithAppPref(NSString *prefApp, NSString *prefKey) {
    NSMutableArray *configs = [[NSMutableArray alloc]init];
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    for (NSString *countConfig in [[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]) {
        if ([[[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]objectForKey:countConfig]objectForKey:prefKey]) {
            [configs addObject:countConfig];
        }
    }
    return [[NSArray alloc]initWithArray:configs];
}
