// Example of how Badger (tweak-side) handles configs

#include <UIKit/UIKit.h>

NSDictionary *badgerPrefs;

%hook SBIconBadgeView
-(void)someExampleHook {
if ([[self superview]isKindOfClass:%c(SBIconView)]) {
 SBIconView *iconView = (SBIconView *)[self superview];
 long badgeCount = [[[self valueForKey:@"_text"] stringByReplacingOccurrencesOfString:@"," withString:@""]integerValue];
NSDictionary *configInUse;
 NSString *configForApp = [[iconView valueForKey:@"_icon"]applicationBundleID];
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
        NSMutableDictionary *badgerPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:documentsDirectory];
        NSMutableDictionary *badgerMutablePrefs = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[badgerPlist objectForKey:@"UniversalConfiguration"],@"UniversalConfiguration", nil];
        NSDictionary *configsForApps = [badgerPlist objectForKey:@"AppConfiguration"];
        if ([[badgerPlist valueForKey:@"UniversalConfiguration"]valueForKey:@"CountSpecificConfigs"]) {
        for (NSString* minimumCountForConfig in [[badgerPlist valueForKey:@"UniversalConfiguration"]valueForKey:@"CountSpecificConfigs"]) {
            [[[[badgerMutablePrefs valueForKey:@"UniversalConfiguration"]objectForKey:@"CountSpecificConfigs"]objectForKey:minimumCountForConfig]addEntriesFromDictionary:[[badgerPlist valueForKey:@"UniversalConfiguration"]objectForKey:@"DefaultConfig"]];
        }
        }
        for (NSString* bundleID in configsForApps) {
            [badgerMutablePrefs setObject:[[NSMutableDictionary alloc]initWithDictionary:[badgerPlist objectForKey:@"UniversalConfiguration"]] forKey:bundleID]; //just adding DefaultConfig from UniversalConfiguration, since a specific app's DefaultConfig should overrule UniversalConfiguration CountsForConfig
            for (NSString *keyNameInDefault in [[configsForApps valueForKey:bundleID]valueForKey:@"DefaultConfig"]) {
                NSMutableDictionary *newDefaultConfig = [[NSMutableDictionary alloc]initWithDictionary:[[badgerMutablePrefs objectForKey:bundleID]objectForKey:@"DefaultConfig"]];
                [newDefaultConfig setObject:[[[configsForApps valueForKey:bundleID]valueForKey:@"DefaultConfig"]valueForKey:keyNameInDefault] forKey:keyNameInDefault];
                [[badgerMutablePrefs objectForKey:bundleID]setObject:newDefaultConfig forKey:@"DefaultConfig"];
            }
            //only add CountSpecificConfig to app if an app specifically has one already
            if ([[configsForApps valueForKey:bundleID]valueForKey:@"CountSpecificConfigs"]) {
                [[badgerMutablePrefs objectForKey:bundleID]setObject:[[NSMutableDictionary alloc]init] forKey:@"CountSpecificConfigs"];
            for (NSString* minimumCountForConfig in [[configsForApps valueForKey:bundleID]valueForKey:@"CountSpecificConfigs"]) {
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
    }
}
