//
//  Popover.m
//  XReader
//
//  Created by Pablo Collins on 10/7/12.
//

#import "Popover.h"
#import <QuartzCore/QuartzCore.h>

@implementation Popover

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 1;
        self.layer.shadowOffset = CGSizeMake(0, 0);
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGFloat ptrH = 12;
    CGFloat ptrB = 30;
    
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height - ptrH;
    
    CGFloat r = 16;
    
    CGFloat ptrOffsetFromCenter = -w/2 + ptrB/2 + r;
    CGFloat ptrLean = 0;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0 + r, 0);
    CGPathAddLineToPoint(path, NULL, w - r, 0);
    
    CGPathAddArcToPoint(path, NULL, w, 0, w, r, r);
    
    CGPathAddLineToPoint(path, NULL, w, h - r);
    
    CGPathAddArcToPoint(path, NULL, w, h, w - r, h, r);
    
    CGFloat ptrBaseRightX = w/2 + ptrB/2 + ptrOffsetFromCenter;
    CGFloat ptrBaseLeftX = w/2 - ptrB/2 + ptrOffsetFromCenter;
    CGPathAddLineToPoint(path, NULL, ptrBaseRightX, h);
    CGPathAddLineToPoint(path, NULL, w/2 + ptrOffsetFromCenter + ptrLean, h + ptrH);
    CGPathAddLineToPoint(path, NULL, ptrBaseLeftX, h);
    
    CGPathAddLineToPoint(path, NULL, r, h);
    
    CGPathAddArcToPoint(path, NULL, 0, h, 0, h - r, r);
    
    CGPathAddLineToPoint(path, NULL, 0, r);
    
    CGPathAddArcToPoint(path, NULL, 0, 0, r, 0, r);
    
    CGPathCloseSubpath(path);
    
    CGContextAddPath(ctx, path);
    
    CGContextClip(ctx);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGFloat colors[6] = {0.4, 1, 0.1, 1, 0.1, 1};
    CGFloat locations[3] = {0, 0.15, 1};
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, 3);
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, 0), CGPointMake(0, self.frame.size.height), 0);
    CFRelease(colorSpace);
    CFRelease(gradient);
    
    CGContextSetRGBFillColor(ctx, 0.2, 0.2, 0.2, 1);
    CGContextFillPath(ctx);

    CGContextRestoreGState(ctx);

    self.layer.shadowPath = path;
    CGPathRelease(path);
}

@end
