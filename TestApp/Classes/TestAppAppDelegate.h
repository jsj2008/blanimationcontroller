//
//  TestAppAppDelegate.h
//  TestApp
//
//  Created by Scott Lawrence on 10/15/09.
//  Copyright UmlautLlama 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TestAppViewController;

@interface TestAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TestAppViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TestAppViewController *viewController;

@end

