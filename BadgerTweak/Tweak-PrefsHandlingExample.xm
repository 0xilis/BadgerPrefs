// Example of how Badger (tweak-side) handles configs

#include <UIKit/UIKit.h>
#include <objc/runtime.h>

NSDictionary *badgerPrefs;

@interface SBIconBadgeView : UIView {
	NSString* _text;
	UIImageView *_textView;
}
@property (nonatomic, assign) NSString* configForApp;
@property (nonatomic, assign) long badgerCount;
@end

BOOL objectContainsIvar(Class _class, const char *name) {
 Ivar ivar = class_getInstanceVariable(_class, name);
 if (!ivar){
  return nil;
 }
 return YES;
}

%hook SBIconBadgeView
%property (nonatomic, assign) NSString* configForApp; //so we don't need to find superview each time
%property (nonatomic, assign) long badgerCount; //so we don't need to stringByReplacingOccurrencesOfString and convert NSString to long each time
%group badgeOption
-(void)someOptionHook {
%orig;
//stuff
}
%end
-(void)someExampleHook {
 %orig;
 NSString *configForApp;
 long badgeCount;
 if ((badgeCount = self.badgerCount)) {
   configForApp = self.configForApp;
 } else {
   if (objectContainsIvar([[self superview] class], "_imageView")) {
     configForApp = [[[[self superview]valueForKey:@"_imageView"]valueForKey:@"_icon"]applicationBundleID];
   } else if (objectContainsIvar([[self superview] class], "_icon")) {
     configForApp = [[[self superview] valueForKey:@"_icon"]applicationBundleID];
   } else {
     return;
   }
   badgeCount = [[[self valueForKey:@"_text"] stringByReplacingOccurrencesOfString:@"," withString:@""]integerValue];
   if (![badgerPrefs objectForKey:configForApp]) {
     configForApp = @"UniversalConfiguration";
   }
   self.badgerCount = badgeCount;
   self.configForApp = configForApp;
 }
 NSDictionary *configInUse = [[badgerPrefs objectForKey:configForApp]objectForKey:@"DefaultConfig"];
 long currentCount = 999999;
 for (NSString *countConfigStr in [[badgerPrefs objectForKey:configForApp]objectForKey:@"CountSpecificConfigs"]) {
   if (badgeCount >= [countConfigStr integerValue]) {
     if ([countConfigStr integerValue] <= currentCount) {
       currentCount = [countConfigStr integerValue];
       if ([[[badgerPrefs objectForKey:configForApp]objectForKey:@"CountSpecificConfigs"]objectForKey:countConfigStr]) {
         configInUse = [[[badgerPrefs objectForKey:configForApp]objectForKey:@"CountSpecificConfigs"]objectForKey:countConfigStr];
       }
     }
   }
 }
//configInUse should now be the current config
}
%end

%ctor {
    @autoreleasepool {
      // insert code here...
      // we want to move our config management in hooks as less as possible for performance, so majority of it is in ctor
      FILE *file;
      if ((file = fopen("/var/mobile/Library/Badger/Prefs/BadgerPrefs.plist","r"))) {
        fclose(file);
        BOOL didEnableOption = NO;
        NSDictionary *badgerPlist = [[NSDictionary alloc]initWithContentsOfFile:@"/var/mobile/Library/Badger/Prefs/BadgerPrefs.plist"];
        if ([[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"DefaultConfig"]objectForKey:@"BadgeOption"]) {
          didEnableOption = YES;
        }
        NSMutableDictionary *badgerMutablePrefs = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[badgerPlist objectForKey:@"UniversalConfiguration"],@"UniversalConfiguration", nil];
        NSDictionary *configsForApps = [badgerPlist objectForKey:@"AppConfiguration"];
        if ([[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]) {
          for (NSString* minimumCountForConfig in [[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]) {
            for (NSString* rawKeyFromConfig in [[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"DefaultConfig"]) {
              if (![[[[badgerPlist objectForKey:@"UniversalConfiguration"] objectForKey:@"CountSpecificConfigs"]objectForKey:minimumCountForConfig]objectForKey:rawKeyFromConfig]) {
                [[[[badgerMutablePrefs objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]objectForKey:minimumCountForConfig]setObject:[[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"DefaultConfig"]objectForKey:rawKeyFromConfig] forKey:rawKeyFromConfig];
              }
            }
          }
        }
        for (NSString* bundleID in configsForApps) {
          [badgerMutablePrefs setObject:[[NSMutableDictionary alloc]initWithDictionary:[badgerPlist objectForKey:@"UniversalConfiguration"]] forKey:bundleID]; //just adding DefaultConfig from UniversalConfiguration, since a specific app's DefaultConfig should overrule UniversalConfiguration CountsForConfig
          for (NSString *keyNameInDefault in [[configsForApps objectForKey:bundleID]objectForKey:@"DefaultConfig"]) {
            if ([keyNameInDefault isEqualToString:@"BadgeOption"]) {
              didEnableOption = YES;
            }
            [[[badgerMutablePrefs objectForKey:bundleID]objectForKey:@"DefaultConfig"]setObject:[[[configsForApps objectForKey:bundleID]objectForKey:@"DefaultConfig"]objectForKey:keyNameInDefault] forKey:keyNameInDefault];
          }
          //only add CountSpecificConfig to app if an app specifically has one already
          for (NSString* minimumCountForConfig in [[configsForApps objectForKey:bundleID]objectForKey:@"CountSpecificConfigs"]) {
            if ([[[[configsForApps objectForKey:bundleID]objectForKey:@"CountSpecificConfigs"]objectForKey:minimumCountForConfig]objectForKey:@"BadgeOption"]) {
              didEnableOption = YES;
            }
            //make the CountSpecificConfig inherit UniversalConfiguration's DefaultConfig, then add UniversalConfiguration's CountSpecificConfigs, then add the app's DefaultConfig, then add the CountSpecificConfig to that
	    [[badgerMutablePrefs objectForKey:bundleID]setObject:[[NSMutableDictionary alloc]initWithObjectsAndKeys:[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"DefaultConfig"],minimumCountForConfig,nil] forKey:@"CountSpecificConfigs"];
            [[[[badgerMutablePrefs objectForKey:bundleID]objectForKey:@"CountSpecificConfigs"]objectForKey:minimumCountForConfig]addEntriesFromDictionary:[[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]objectForKey:minimumCountForConfig]];
            [[[[badgerMutablePrefs objectForKey:bundleID]objectForKey:@"CountSpecificConfigs"]objectForKey:minimumCountForConfig]addEntriesFromDictionary:[[configsForApps objectForKey:bundleID]objectForKey:@"DefaultConfig"]];
            [[[[badgerMutablePrefs objectForKey:bundleID]objectForKey:@"CountSpecificConfigs"]objectForKey:minimumCountForConfig] addEntriesFromDictionary:[[[configsForApps objectForKey:bundleID]objectForKey:@"CountSpecificConfigs"]objectForKey:minimumCountForConfig]];
          }
        }
        badgerPrefs = [[NSDictionary alloc]initWithDictionary:badgerMutablePrefs];
        if (didEnableOption) {%init(badgeOption)};
      } else {
        badgerPrefs = [[NSDictionary alloc]initWithObjectsAndKeys:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSDictionary alloc]init],@"DefaultConfig", nil],@"UniversalConfiguration",[[NSDictionary alloc]init],@"AppConfiguration", nil];
      }
    }
        
    %init(_ungrouped);
}
