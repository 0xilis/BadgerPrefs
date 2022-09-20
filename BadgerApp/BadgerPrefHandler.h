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
void badgerSaveUniversalCountPref(int count, NSString *prefKey, id prefValue);
void badgerSaveAppCountPref(int count, NSString *prefApp, NSString *prefKey, id prefValue);
void badgerRemoveUniversalPref(NSString *prefKey);
void badgerRemoveAppPref(NSString *prefApp, NSString *prefKey);
void badgerRemoveUniversalCountPref(int count, NSString *prefKey);
void badgerRemoveAppCountPref(int count, NSString *prefApp, NSString *prefKey);
void badgerSetUpPrefPlist(void);
id badgerRetriveUniversalPref(NSString *prefKey);
id badgerRetriveAppPref(NSString *prefApp, NSString *prefKey);
id badgerRetriveUniversalCountPref(int count, NSString *prefKey);
id badgerRetriveAppCountPref(int count, NSString *prefApp, NSString *prefKey);
NSArray *badgerRetriveConfigsWithUniversalPref(NSString *prefKey);
NSArray *badgerRetriveConfigsWithAppPref(NSString *prefApp, NSString *prefKey);
#endif /* BadgerPrefHandler_h */
