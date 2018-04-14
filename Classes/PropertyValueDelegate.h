//
//  TagValueDelegate.h
//  XReader
//
//  Created by Pablo Collins on 11/20/10.
//

#import <UIKit/UIKit.h>

@protocol PropertyValueDelegate

- (void)handlerFoundValue:(NSString *)str forName:(NSString *)name property:(NSString *)property;

@end
