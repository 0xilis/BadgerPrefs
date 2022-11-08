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

void badgerSetUpPrefPlist(NSString *preferencesDirectory){
    NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[[NSMutableDictionary alloc]initWithObjectsAndKeys:[[NSMutableDictionary alloc]init],@"DefaultConfig", nil],@"UniversalConfiguration",[[NSMutableDictionary alloc]init],@"AppConfiguration", nil];
    NSError* error=nil;
    NSPropertyListFormat format=NSPropertyListXMLFormat_v1_0;
    NSData* data =  [NSPropertyListSerialization dataWithPropertyList:badgerPlist format:format options:NSPropertyListImmutable error:&error];
    [data writeToFile:preferencesDirectory atomically:YES];
}

%ctor {
    @autoreleasepool {
        // insert code here...
        // we want to move our config management in hooks as less as possible for performance, so majority of it is in ctor
        NSString *documentsDirectory = @"/var/mobile/Library/Badger/Prefs/BadgerPrefs.plist";
        FILE *file;
        if ((file = fopen("/var/mobile/Library/Badger/Prefs/BadgerPrefs.plist","r"))) {
          fclose(file);
        } else {
          badgerSetUpPrefPlist(documentsDirectory);
        }
        BOOL didEnableOption = NO;
        NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:documentsDirectory];
        if ([[[[badgerPlist valueForKey:@"UniversalConfiguration"]valueForKey:@"DefaultConfig"]allKeys]containsObject:@"BadgeOption"]) {
            didEnableOption = YES;
        }
        NSMutableDictionary *badgerMutablePrefs = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[badgerPlist objectForKey:@"UniversalConfiguration"],@"UniversalConfiguration", nil];
        NSDictionary *configsForApps = [badgerPlist objectForKey:@"AppConfiguration"];
        if ([[badgerPlist valueForKey:@"UniversalConfiguration"]valueForKey:@"CountSpecificConfigs"]) {
        for (NSString* minimumCountForConfig in [[badgerPlist valueForKey:@"UniversalConfiguration"]valueForKey:@"CountSpecificConfigs"]) {
            if ([[[[[badgerPlist valueForKey:@"UniversalConfiguration"]valueForKey:@"CountSpecificConfigs"]valueForKey:minimumCountForConfig]allKeys]containsObject:@"BadgeOption"]) {
            didEnableOption = YES;
            }
            [[[[badgerMutablePrefs valueForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]objectForKey:minimumCountForConfig]addEntriesFromDictionary:[[badgerPlist valueForKey:@"UniversalConfiguration"]objectForKey:@"DefaultConfig"]];
        }
        }
        for (NSString* bundleID in configsForApps) {
            [badgerMutablePrefs setObject:[[NSMutableDictionary alloc]initWithDictionary:[badgerPlist objectForKey:@"UniversalConfiguration"]] forKey:bundleID]; //just adding DefaultConfig from UniversalConfiguration, since a specific app's DefaultConfig should overrule UniversalConfiguration CountsForConfig
            for (NSString *keyNameInDefault in [[configsForApps valueForKey:bundleID]valueForKey:@"DefaultConfig"]) {
                if ([keyNameInDefault isEqualToString:@"BadgeOption"]) {
                didEnableOption = YES;
                }
                NSMutableDictionary *newDefaultConfig = [[NSMutableDictionary alloc]initWithDictionary:[[badgerMutablePrefs objectForKey:bundleID]objectForKey:@"DefaultConfig"]];
                [newDefaultConfig setObject:[[[configsForApps valueForKey:bundleID]valueForKey:@"DefaultConfig"]valueForKey:keyNameInDefault] forKey:keyNameInDefault];
                [[badgerMutablePrefs objectForKey:bundleID]setObject:newDefaultConfig forKey:@"DefaultConfig"];
            }
            //only add CountSpecificConfig to app if an app specifically has one already
            if ([[configsForApps valueForKey:bundleID]valueForKey:@"CountSpecificConfigs"]) {
                [[badgerMutablePrefs objectForKey:bundleID]setObject:[[NSMutableDictionary alloc]init] forKey:@"CountSpecificConfigs"];
            for (NSString* minimumCountForConfig in [[configsForApps valueForKey:bundleID]valueForKey:@"CountSpecificConfigs"]) {
                if ([[[[[configsForApps valueForKey:bundleID]valueForKey:@"CountSpecificConfigs"]valueForKey:minimumCountForConfig]allKeys]containsObject:@"BadgeOption"]) {
            didEnableOption = YES;
                }
                //make the CountSpecificConfig inherit UniversalConfiguration's DefaultConfig, then add UniversalConfiguration's CountSpecificConfigs, then add the app's DefaultConfig, then add the CountSpecificConfig to that
                [[[badgerMutablePrefs valueForKey:bundleID]objectForKey:@"CountSpecificConfigs"] setObject:[[NSMutableDictionary alloc]init] forKey:minimumCountForConfig];
                [[[[badgerMutablePrefs valueForKey:bundleID]objectForKey:@"CountSpecificConfigs"]objectForKey:minimumCountForConfig]addEntriesFromDictionary:[[configsForApps valueForKey:bundleID]objectForKey:@"DefaultConfig"]];
                [[[[badgerMutablePrefs valueForKey:bundleID]objectForKey:@"CountSpecificConfigs"]objectForKey:minimumCountForConfig]addEntriesFromDictionary:[[badgerPlist valueForKey:@"UniversalConfiguration"]objectForKey:@"DefaultConfig"]];
                [[[[badgerMutablePrefs valueForKey:bundleID]objectForKey:@"CountSpecificConfigs"]objectForKey:minimumCountForConfig]addEntriesFromDictionary:[[[badgerPlist valueForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]objectForKey:minimumCountForConfig]];
                [[[[badgerMutablePrefs valueForKey:bundleID]objectForKey:@"CountSpecificConfigs"]objectForKey:minimumCountForConfig]addEntriesFromDictionary:[[configsForApps valueForKey:bundleID]objectForKey:@"DefaultConfig"]];
                [[[[badgerMutablePrefs valueForKey:bundleID]objectForKey:@"CountSpecificConfigs"]objectForKey:minimumCountForConfig] addEntriesFromDictionary:[[[configsForApps valueForKey:bundleID]valueForKey:@"CountSpecificConfigs"]objectForKey:minimumCountForConfig]];
            }
            }
        }
        badgerPrefs = [[NSDictionary alloc]initWithDictionary:badgerMutablePrefs];
        if (didEnableOption) {%init(badgeOption)};
    }
    %init(_ungrouped);
}
