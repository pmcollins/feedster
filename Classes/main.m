//
//  main.m
//  XReader
//
//  Created by Pablo Collins on 10/24/10.
//

#import <UIKit/UIKit.h>
#import "XReaderAppDelegate.h"
#import "ReaderApplication.h"

int main(int argc, char *argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc,
                                 argv,
                                 NSStringFromClass([ReaderApplication class]),
                                 NSStringFromClass([XReaderAppDelegate class]));
    }
}
