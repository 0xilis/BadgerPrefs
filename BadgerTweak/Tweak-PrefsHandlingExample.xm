// Example of how Badger (tweak-side) handles configs

#include <UIKit/UIKit.h>
#include <objc/runtime.h>

NSDictionary *badgerPrefs;

BOOL objectContainsIvar(Class _class, const char *name) {
 Ivar ivar = class_getInstanceVariable(_class, name);
 if (!ivar){
  return nil;
 }
 return YES;
}

%hook SBIconBadgeView
%group badgeOption
-(void)someOptionHook {
%orig;
//stuff
}
%end
-(void)someExampleHook {
 %orig;
 NSString *configForApp;
 if(objectContainsIvar([[self superview] class], "_imageView")) {
  configForApp = [[[[self superview]valueForKey:@"_imageView"]valueForKey:@"_icon"]applicationBundleID];
 } else if (objectContainsIvar([[self superview] class], "_icon")) {
  configForApp = [[[self superview] valueForKey:@"_icon"]applicationBundleID];
 } else {
  return;
 }
 long badgeCount = [[[self valueForKey:@"_text"] stringByReplacingOccurrencesOfString:@"," withString:@""]integerValue];
 NSDictionary *configInUse;
 if (![badgerPrefs objectForKey:configForApp]) {
    configForApp = @"UniversalConfiguration";
 }
 if ((badgeCount >= [[[[[badgerPrefs objectForKey:configForApp]objectForKey:@"CountSpecificConfigs"]allKeys]firstObject]integerValue]) && [[badgerPrefs objectForKey:configForApp]objectForKey:@"CountSpecificConfigs"]) {
 long repeat = [[[[badgerPrefs objectForKey:configForApp]objectForKey:@"CountSpecificConfigs"] allKeys]count] - 1;
    while (!(badgeCount >= [[[[[badgerPrefs objectForKey:configForApp]objectForKey:@"CountSpecificConfigs"]allKeys]objectAtIndex:repeat]integerValue])) {
        repeat--;
        if (repeat == -1) {
            break;
        }
    }
    if (repeat == -1) {
        NSLog(@"Badger failed to find count config for %@",configForApp);
        configInUse = [[NSDictionary alloc]initWithDictionary:[[badgerPrefs objectForKey:configForApp]objectForKey:@"DefaultConfig"]];
    } else {
        configInUse = [[NSDictionary alloc]initWithDictionary:[[[badgerPrefs objectForKey:configForApp]objectForKey:@"CountSpecificConfigs"]objectForKey:[[[[badgerPrefs objectForKey:configForApp]objectForKey:@"CountSpecificConfigs"]allKeys]objectAtIndex:repeat]]];
    }
 } else {
   configInUse = [[NSDictionary alloc]initWithDictionary:[[badgerPrefs objectForKey:configForApp]objectForKey:@"DefaultConfig"]];
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
        NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:@"/var/mobile/Library/Badger/Prefs/BadgerPrefs.plist"];
        if ([[[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"DefaultConfig"]allKeys]containsObject:@"BadgeOption"]) {
          didEnableOption = YES;
        }
        NSMutableDictionary *badgerMutablePrefs = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[badgerPlist objectForKey:@"UniversalConfiguration"],@"UniversalConfiguration", nil];
        NSDictionary *configsForApps = [badgerPlist objectForKey:@"AppConfiguration"];
        if ([[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]) {
          for (NSString* minimumCountForConfig in [[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]) {
            if ([[[[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]objectForKey:minimumCountForConfig]allKeys]containsObject:@"BadgeOption"]) {
              didEnableOption = YES;
            }
            [[[[badgerMutablePrefs objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]objectForKey:minimumCountForConfig]addEntriesFromDictionary:[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"DefaultConfig"]];
          }
        }
        for (NSString* bundleID in configsForApps) {
          [badgerMutablePrefs setObject:[[NSMutableDictionary alloc]initWithDictionary:[badgerPlist objectForKey:@"UniversalConfiguration"]] forKey:bundleID]; //just adding DefaultConfig from UniversalConfiguration, since a specific app's DefaultConfig should overrule UniversalConfiguration CountsForConfig
          for (NSString *keyNameInDefault in [[configsForApps objectForKey:bundleID]objectForKey:@"DefaultConfig"]) {
            if ([keyNameInDefault isEqualToString:@"BadgeOption"]) {
              didEnableOption = YES;
            }
            NSMutableDictionary *newDefaultConfig = [[NSMutableDictionary alloc]initWithDictionary:[[badgerMutablePrefs objectForKey:bundleID]objectForKey:@"DefaultConfig"]];
            [newDefaultConfig setObject:[[[configsForApps objectForKey:bundleID]objectForKey:@"DefaultConfig"]objectForKey:keyNameInDefault] forKey:keyNameInDefault];
            [[badgerMutablePrefs objectForKey:bundleID]setObject:newDefaultConfig forKey:@"DefaultConfig"];
          }
          //only add CountSpecificConfig to app if an app specifically has one already
          if ([[configsForApps objectForKey:bundleID]objectForKey:@"CountSpecificConfigs"]) {
            [[badgerMutablePrefs objectForKey:bundleID]setObject:[[NSMutableDictionary alloc]init] forKey:@"CountSpecificConfigs"];
            for (NSString* minimumCountForConfig in [[configsForApps objectForKey:bundleID]objectForKey:@"CountSpecificConfigs"]) {
              if ([[[[[configsForApps objectForKey:bundleID]objectForKey:@"CountSpecificConfigs"]objectForKey:minimumCountForConfig]allKeys]containsObject:@"BadgeOption"]) {
                didEnableOption = YES;
              }
              //make the CountSpecificConfig inherit UniversalConfiguration's DefaultConfig, then add UniversalConfiguration's CountSpecificConfigs, then add the app's DefaultConfig, then add the CountSpecificConfig to that
              [[[badgerMutablePrefs objectForKey:bundleID]objectForKey:@"CountSpecificConfigs"] setObject:[[NSMutableDictionary alloc]init] forKey:minimumCountForConfig];
              [[[[badgerMutablePrefs objectForKey:bundleID]objectForKey:@"CountSpecificConfigs"]objectForKey:minimumCountForConfig]addEntriesFromDictionary:[[configsForApps objectForKey:bundleID]objectForKey:@"DefaultConfig"]];
              [[[[badgerMutablePrefs objectForKey:bundleID]objectForKey:@"CountSpecificConfigs"]objectForKey:minimumCountForConfig]addEntriesFromDictionary:[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"DefaultConfig"]];
              [[[[badgerMutablePrefs objectForKey:bundleID]objectForKey:@"CountSpecificConfigs"]objectForKey:minimumCountForConfig]addEntriesFromDictionary:[[[badgerPlist objectForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]objectForKey:minimumCountForConfig]];
              [[[[badgerMutablePrefs objectForKey:bundleID]objectForKey:@"CountSpecificConfigs"]objectForKey:minimumCountForConfig]addEntriesFromDictionary:[[configsForApps objectForKey:bundleID]objectForKey:@"DefaultConfig"]];
              [[[[badgerMutablePrefs objectForKey:bundleID]objectForKey:@"CountSpecificConfigs"]objectForKey:minimumCountForConfig] addEntriesFromDictionary:[[[configsForApps objectForKey:bundleID]objectForKey:@"CountSpecificConfigs"]objectForKey:minimumCountForConfig]];
            }
          }
        }
        badgerPrefs = [[NSDictionary alloc]initWithDictionary:badgerMutablePrefs];
        if (didEnableOption) {%init(badgeOption)};
      } else {
        badgerPrefs = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[[NSMutableDictionary alloc]initWithObjectsAndKeys:[[NSMutableDictionary alloc]init],@"DefaultConfig", nil],@"UniversalConfiguration",[[NSMutableDictionary alloc]init],@"AppConfiguration", nil];
      }
    }
        
    %init(_ungrouped);
}
