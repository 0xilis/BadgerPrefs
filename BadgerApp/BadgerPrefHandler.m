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

void badgerSaveUniversalCountPref(int count, NSString *prefKey, id prefValue) {
    //For Custom Labels & Custom Images
    //REMEMBER, sort countsforconfigs by least to greatest
    //ex get maximum count config (includes one being added), make a new dict and repeat from 0 till max that if count config exists add it to new dict, and then use that new dict
    //some problems might arrive with this approach once we get into mixing app countspecificconfigs from universalconfig with appconfigs but for now the badger app does *not* have any countspecificconfigs for an app config, so I'll worry about it later
    //issue is tweak side and not with BadgerPrefHandler, that being even though App Counts and Universal Counts are sorted from least to greatest, when Badger merges the two it doesn't resort them
    //maybe when that time comes, make init autosort by getting the biggest count specific config, and form new dict from that
    //also, we limit badge count to be less than 9999, we already take this into account on our view controllers but just in case
    if (count < 9999) {
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    if ([[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]) {
        if (![[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]objectForKey:[NSString stringWithFormat:@"%d",count]]) {
            //alphabetically sort configs and create new config
        NSMutableDictionary *newSortedCountConfigs = [[NSMutableDictionary alloc]init];
        int max = (int)[[[[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]allKeys]lastObject]integerValue];
        if (max < count) {
            max = count;
        }
        BOOL placedNewCountConfig = NO;
        for (NSString* countConfigString in [[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]allKeys]) {
            int countConfig = (int)[countConfigString integerValue];
            
            if (count >= countConfig && !placedNewCountConfig) {
                [newSortedCountConfigs setObject:[[NSMutableDictionary alloc]initWithObjectsAndKeys:prefValue,prefKey,nil] forKey:[NSString stringWithFormat:@"%d",count]];
                placedNewCountConfig = YES;
            }
            [newSortedCountConfigs setObject:[[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]objectForKey:countConfigString] forKey:countConfigString];
            }
        if (!placedNewCountConfig) {
            [newSortedCountConfigs setObject:[[NSMutableDictionary alloc]initWithObjectsAndKeys:prefValue,prefKey,nil] forKey:[NSString stringWithFormat:@"%d",count]];
        }
            [[badgerPlist objectForKey:@"UniversalConfiguration"] setObject:newSortedCountConfigs forKey:@"CountSpecificConfigs"];
        } else {
            //if we already have the count config, we don't need to alphabetically sort
            [[[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]objectForKey:[NSString stringWithFormat:@"%d",count]]setObject:prefValue forKey:prefKey];
        }
    
    } else {
        [[badgerPlist objectForKey:@"UniversalConfiguration"]setObject:[[NSMutableDictionary alloc]init] forKey:@"CountSpecificConfigs"];
        [[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]setObject:[[NSMutableDictionary alloc]initWithObjectsAndKeys:prefValue,prefKey, nil] forKey:[NSString stringWithFormat:@"%d",count]];
    }
    [badgerPlist writeToFile:preferencesDirectory atomically:YES];
    
    }
}

void badgerSaveAppCountPref(int count, NSString *prefApp, NSString *prefKey, id prefValue) {
    if (count < 9999) {
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    if ([[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]) {
        if (![[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]objectForKey:[NSString stringWithFormat:@"%d",count]]) {
            //alphabetically sort configs and create new config
        NSMutableDictionary *newSortedCountConfigs = [[NSMutableDictionary alloc]init];
        int max = (int)[[[[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]allKeys]lastObject]integerValue];
        if (max < count) {
            max = count;
        }
        BOOL placedNewCountConfig = NO;
        for (NSString* countConfigString in [[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]allKeys]) {
            int countConfig = (int)[countConfigString integerValue];
            
            if (count >= countConfig && !placedNewCountConfig) {
                [newSortedCountConfigs setObject:[[NSMutableDictionary alloc]initWithObjectsAndKeys:prefValue,prefKey,nil] forKey:[NSString stringWithFormat:@"%d",count]];
                placedNewCountConfig = YES;
            }
            [newSortedCountConfigs setObject:[[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]objectForKey:countConfigString] forKey:countConfigString];
            }
        if (!placedNewCountConfig) {
            [newSortedCountConfigs setObject:[[NSMutableDictionary alloc]initWithObjectsAndKeys:prefValue,prefKey,nil] forKey:[NSString stringWithFormat:@"%d",count]];
        }
            [[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp] setObject:newSortedCountConfigs forKey:@"CountSpecificConfigs"];
        } else {
            //if we already have the count config, we don't need to alphabetically sort
            [[[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]objectForKey:[NSString stringWithFormat:@"%d",count]]setObject:prefValue forKey:prefKey];
        }
    
    } else {
        if (![[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]) {
            [[badgerPlist objectForKey:@"AppConfiguration"]setObject:[[NSMutableDictionary alloc]init] forKey:prefApp];
        }
        [[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]setObject:[[NSMutableDictionary alloc]init] forKey:@"CountSpecificConfigs"];
        [[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]setObject:[[NSMutableDictionary alloc]initWithObjectsAndKeys:prefValue,prefKey, nil] forKey:[NSString stringWithFormat:@"%d",count]];
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

void badgerRemoveUniversalCountPref(int count, NSString *prefKey) {
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    if ([[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]objectForKey:[NSString stringWithFormat:@"%d",count]]) {
        if ([[[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]objectForKey:[NSString stringWithFormat:@"%d",count]]count] == 1) {
            //since we're removing the only pref the count config has, might as well free the whole count config altogether
            if ([[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]count] <= 1) {
                [[badgerPlist objectForKey:@"UniversalConfiguration"]removeObjectForKey:@"CountSpecificConfigs"];
            } else {
                [[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]removeObjectForKey:[NSString stringWithFormat:@"%d",count]];
            }
        } else {
            [[[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]objectForKey:[NSString stringWithFormat:@"%d",count]]removeObjectForKey:prefKey];
        }
        [badgerPlist writeToFile:preferencesDirectory atomically:YES];
    }
}

void badgerRemoveAppCountPref(int count, NSString *prefApp, NSString *prefKey) {
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    if ([[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]objectForKey:[NSString stringWithFormat:@"%d",count]]) {
        if ([[[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]objectForKey:[NSString stringWithFormat:@"%d",count]]count] == 1) {
            //since we're removing the only pref the count config has, might as well free the whole count config altogether
            if ([[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]count] == 1) {
                if ([[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]count] == 1) {
                    [[badgerPlist objectForKey:@"AppConfiguration"]removeObjectForKey:prefApp];
                } else {
                    [[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]removeObjectForKey:@"CountSpecificConfigs"];
                }
            } else {
                [[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]removeObjectForKey:[NSString stringWithFormat:@"%d",count]];
            }
        } else {
            [[[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]objectForKey:[NSString stringWithFormat:@"%d",count]]removeObjectForKey:prefKey];
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

id badgerRetriveUniversalCountPref(int count, NSString *prefKey) {
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    if ([[[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]objectForKey:[NSString stringWithFormat:@"%d",count]]objectForKey:prefKey]) {
        return [[[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]objectForKey:[NSString stringWithFormat:@"%d",count]]objectForKey:prefKey];
    }
    return NULL;
}

id badgerRetriveAppCountPref(int count, NSString *prefApp, NSString *prefKey) {
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesDirectory];
    if ([[[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]objectForKey:[NSString stringWithFormat:@"%d",count]]objectForKey:prefKey]) {
        return [[[[[badgerPlist objectForKey:@"AppConfiguration"]objectForKey:prefApp]objectForKey:@"CountSpecificConfigs"]objectForKey:[NSString stringWithFormat:@"%d",count]]objectForKey:prefKey];
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
