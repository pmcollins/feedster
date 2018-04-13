#import "GradientButton.h"

@interface GradientButton()
{
    CGGradientRef _normalGradient, _highlightGradient, _disabledGradient;
    NSArray *_normalGradientLocations, *_normalGradientColors,
            *_highlightGradientLocations, *_highlightGradientColors,
            *_disabledGradientLocations, *_disabledGradientColors;
}
@end

@implementation GradientButton

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder:decoder])
    {
        [self setupColors];
    }
    return self;
}

- (CGGradientRef)normalGradient
{
    if (_normalGradient == NULL)
    {
        NSUInteger locCount = [_normalGradientLocations count];
        CGFloat locations[locCount];
        for (int i = 0; i < [_normalGradientLocations count]; i++)
        {
            NSNumber *location = _normalGradientLocations[i];
            locations[i] = [location floatValue];
        }
        
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        _normalGradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)_normalGradientColors, locations);
        CGColorSpaceRelease(space);
    }
    return _normalGradient;
}

- (CGGradientRef)highlightGradient
{
    if (_highlightGradient == NULL)
    {
        CGFloat locations[[_highlightGradientLocations count]];
        for (int i = 0; i < [_highlightGradientLocations count]; i++)
        {
            NSNumber *location = _highlightGradientLocations[i];
            locations[i] = [location floatValue];
        }
        
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        _highlightGradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)_highlightGradientColors, locations);
        CGColorSpaceRelease(space);
    }
    return _highlightGradient;
}

- (CGGradientRef)disabledGradient
{
    if (_disabledGradient == NULL)
    {
        NSUInteger locCount = [_disabledGradientLocations count];
        CGFloat locations[locCount];
        for (int i = 0; i < [_disabledGradientLocations count]; i++)
        {
            NSNumber *location = _disabledGradientLocations[i];
            locations[i] = [location floatValue];
        }
        
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        _disabledGradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)_disabledGradientColors, locations);
        CGColorSpaceRelease(space);
    }
    return _disabledGradient;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
    {
		[self setOpaque:NO];
        self.backgroundColor = [UIColor clearColor];
        [self setupColors];
	}
	return self;
}

- (void)setupColors
{
    _normalGradientColors = @[
        (id)[[UIColor colorWithWhite:0.5 alpha:1.0] CGColor],
        (id)[[UIColor colorWithWhite:0.0 alpha:1.0] CGColor]
    ];
    _normalGradientLocations = @[@0.0, @0.7];
    
    _highlightGradientColors = @[
        (id)[[UIColor colorWithWhite:0.7 alpha:1.0] CGColor],
        (id)[[UIColor colorWithWhite:0.2 alpha:1.0] CGColor]
    ];
    _highlightGradientLocations = @[@0.0, @0.7];
    
    _disabledGradientColors = @[
        (id)[[UIColor colorWithWhite:0.0 alpha:1.0] CGColor]
    ];
    _disabledGradientLocations = @[@0.0];
    
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGFloat r = 7;
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    CGFloat p = 0;
    CGFloat lineWidth = 1;
    
    CGPoint tlc = CGPointMake(p, p);
    
    CGPoint tl = CGPointMake(r + p, p);
    CGPoint tr = CGPointMake(w - r - p, p);
    
    CGPoint trc = CGPointMake(w - p, p);
    
    CGPoint rt = CGPointMake(w - p, r + p);
    CGPoint rb = CGPointMake(w - p, h - r - p);
    
    CGPoint brc = CGPointMake(w - p, h - p);
    
    CGPoint bl = CGPointMake(r + p, h - p);
    CGPoint br = CGPointMake(w - r - p, h - p);
    
    CGPoint blc = CGPointMake(p, h - p);
    
    CGPoint lt = CGPointMake(p, r + p);
    CGPoint lb = CGPointMake(p, h - r - p);
    
    //black top edge
    CGPathMoveToPoint(path, NULL, lt.x, lt.y);
    
    CGPathAddArcToPoint(path, NULL, tlc.x, tlc.y, tl.x, tl.y, r);
    
    CGPathAddLineToPoint(path, NULL, tr.x, tr.y);
    
    CGPathAddArcToPoint(path, NULL, trc.x, trc.y, rt.x, rt.y, r);
    
    CGContextAddPath(ctx, path);
    CGContextClip(ctx);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextSetStrokeColorWithColor(ctx, [[UIColor blackColor] CGColor]);
    CGContextAddPath(ctx, path);
    CGContextStrokePath(ctx);
    CFRelease(path);
    
    CGContextRestoreGState(ctx);
    
    //light sides and bottom
    ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, rt.x, rt.y);
    CGPathAddLineToPoint(path, NULL, rb.x, rb.y);
    
    CGPathAddArcToPoint(path, NULL, brc.x, brc.y, br.x, br.y, r);
    
    CGPathAddLineToPoint(path, NULL, bl.x, bl.y);
    
    CGPathAddArcToPoint(path, NULL, blc.x, blc.y, lb.x, lb.y, r);
    
    CGPathAddLineToPoint(path, NULL, lt.x, lt.y);
    
    CGContextAddPath(ctx, path);
    CGContextClip(ctx);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextSetStrokeColorWithColor(ctx, [[UIColor blackColor] CGColor]);
    CGContextAddPath(ctx, path);
	CGContextStrokePath(ctx);
    
    CFRelease(path);
    
    CGContextRestoreGState(ctx);
    
    //creamy center
    ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    path = CGPathCreateMutable();
    
    p = 0.5;
    r = 6;
    
    tlc = CGPointMake(p, p);
    
    tl = CGPointMake(r + p, p);
    tr = CGPointMake(w - r - p, p);
    
    trc = CGPointMake(w - p, p);
    
    rt = CGPointMake(w - p, r + p);
    rb = CGPointMake(w - p, h - r - p);
    
    brc = CGPointMake(w - p, h - p);
    
    bl = CGPointMake(r + p, h - p);
    br = CGPointMake(w - r - p, h - p);
    
    blc = CGPointMake(p, h - p);
    
    lt = CGPointMake(p, r + p);
    lb = CGPointMake(p, h - r - p);
    
    CGPathMoveToPoint(path, NULL, tl.x, tl.y);
    
    CGPathAddLineToPoint(path, NULL, tr.x, tr.y);
    
    CGPathAddArcToPoint(path, NULL, trc.x, trc.y, rt.x, rt.y, r);
    
    CGPathAddLineToPoint(path, NULL, rb.x, rb.y);
    
    CGPathAddArcToPoint(path, NULL, brc.x, brc.y, br.x, br.y, r);
    
    CGPathAddLineToPoint(path, NULL, bl.x, bl.y);
    
    CGPathAddArcToPoint(path, NULL, blc.x, blc.y, lb.x, lb.y, r);
    
    CGPathAddLineToPoint(path, NULL, lt.x, lt.y);
    
    CGPathAddArcToPoint(path, NULL, tlc.x, tlc.y, tl.x, tl.y, r);
    
    CGPathCloseSubpath(path);
    
    CGContextAddPath(ctx, path);
    
    CGContextClip(ctx);
    
    CGGradientRef gradient = self.enabled ?
        ((self.state == UIControlStateHighlighted) ? [self highlightGradient] : [self normalGradient]) :
        [self disabledGradient];
	CGPoint startGrad = CGPointMake(w / 2, p);
	CGPoint endGrad = CGPointMake(w / 2, h - p);
	CGContextDrawLinearGradient(ctx, gradient, startGrad, endGrad, (kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation));
    
    CFRelease(path);
    
    CGContextRestoreGState(ctx);
}

- (void)hesitateUpdate
{
    [self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self setNeedsDisplay];
    [self performSelector:@selector(hesitateUpdate) withObject:nil afterDelay:0.1];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self setNeedsDisplay];
    [self performSelector:@selector(hesitateUpdate) withObject:nil afterDelay:0.1];
}

- (void)dealloc
{
    if (_normalGradient != NULL)
        CGGradientRelease(_normalGradient);
    if (_highlightGradient != NULL)
        CGGradientRelease(_highlightGradient);
}

@end
