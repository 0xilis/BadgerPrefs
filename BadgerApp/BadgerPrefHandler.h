//
//  BadgerPrefHandler.h
//  BadgerApp
//
//  Created by Snoolie Keffaber on 9/9/22.
//

#ifndef BadgerPrefHandler_h
#define BadgerPrefHandler_h

#include <UIKit/UIKit.h>

void badgerSaveUniversalPref(NSString *prefKey, id prefValue);
void badgerSaveAppPref(NSString *prefApp, NSString *prefKey, id prefValue);
void badgerSaveUniversalCountPref(long count, NSString *prefKey, id prefValue);
void badgerSaveAppCountPref(long count, NSString *prefApp, NSString *prefKey, id prefValue);
void badgerRemoveUniversalPref(NSString *prefKey);
void badgerRemoveAppPref(NSString *prefApp, NSString *prefKey);
void badgerRemoveUniversalCountPref(long count, NSString *prefKey);
void badgerRemoveAppCountPref(long count, NSString *prefApp, NSString *prefKey);
void badgerSetUpPrefPlist(void);
void badgerSetUpPrefPlistAtSpecificLocation(NSString *specifiedDirectory);
id badgerRetriveUniversalPref(NSString *prefKey);
id badgerRetriveAppPref(NSString *prefApp, NSString *prefKey);
id badgerRetriveUniversalCountPref(long count, NSString *prefKey);
id badgerRetriveAppCountPref(long count, NSString *prefApp, NSString *prefKey);
NSArray *badgerRetriveConfigsWithUniversalPref(NSString *prefKey);
NSArray *badgerRetriveConfigsWithAppPref(NSString *prefApp, NSString *prefKey);
#endif /* BadgerPrefHandler_h */
