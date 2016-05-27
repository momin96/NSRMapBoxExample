//
//  LoadingView.m
//  LoadingView
//
//  Created by Matt Gallagher on 12/04/09.
//  Copyright Matt Gallagher 2009. All rights reserved.
// 
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "CRLoadingView.h"
#import <QuartzCore/QuartzCore.h>

#define titleLabelTag 666

CGPathRef New2PathWithRoundRect(CGRect rect, CGFloat cornerRadius);

CGPathRef New2PathWithRoundRect(CGRect rect, CGFloat cornerRadius)
{
	//
	// Create the boundary path
	//
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL,
		rect.origin.x,
		rect.origin.y + rect.size.height - cornerRadius);

	// Top left corner
	CGPathAddArcToPoint(path, NULL,
		rect.origin.x,
		rect.origin.y,
		rect.origin.x + rect.size.width,
		rect.origin.y,
		cornerRadius);

	// Top right corner
	CGPathAddArcToPoint(path, NULL,
		rect.origin.x + rect.size.width,
		rect.origin.y,
		rect.origin.x + rect.size.width,
		rect.origin.y + rect.size.height,
		cornerRadius);

	// Bottom right corner
	CGPathAddArcToPoint(path, NULL,
		rect.origin.x + rect.size.width,
		rect.origin.y + rect.size.height,
		rect.origin.x,
		rect.origin.y + rect.size.height,
		cornerRadius);

	// Bottom left corner
	CGPathAddArcToPoint(path, NULL,
		rect.origin.x,
		rect.origin.y + rect.size.height,
		rect.origin.x,
		rect.origin.y,
		cornerRadius);

	// Close the path at the rounded rect
	CGPathCloseSubpath(path);
	
	return path;
}

static CRLoadingView *loadingView = nil;;

@implementation CRLoadingView

+(void)setTitle:(NSString*)inTitle
{
    UILabel *titleLabel = (UILabel *)[loadingView viewWithTag:titleLabelTag];
    titleLabel.text = inTitle;
}

+(id)loadingViewInView:(UIView *)aSuperview Title:(NSString*)title
{	
    if(nil != loadingView.superview){
        [loadingView removeFromSuperview];
        loadingView = nil;
    }
    
    //aSuperview.userInteractionEnabled = NO;
    if(nil == loadingView){
        loadingView = [[CRLoadingView alloc] initWithFrame:[aSuperview bounds]];
        if (!loadingView){
            return nil;
        }
        loadingView.opaque = NO;
        loadingView.autoresizingMask =
		UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [aSuperview addSubview:loadingView];
        loadingView.userInteractionEnabled = YES;
        const CGFloat DEFAULT_LABEL_WIDTH = 280.0;
        const CGFloat DEFAULT_LABEL_HEIGHT = 50.0;
        CGRect labelFrame = CGRectMake(0, 0, DEFAULT_LABEL_WIDTH, DEFAULT_LABEL_HEIGHT);
        UILabel *loadingLabel =
		[[UILabel alloc] initWithFrame:labelFrame];
        [loadingLabel setNumberOfLines:2];
        loadingLabel.tag = titleLabelTag;
        loadingLabel.text = NSLocalizedString(title, nil);
        loadingLabel.textColor = [UIColor whiteColor];
        loadingLabel.backgroundColor = [UIColor clearColor];
        loadingLabel.textAlignment = NSTextAlignmentCenter;
        loadingLabel.font = [UIFont boldSystemFontOfSize:14];
        loadingLabel.autoresizingMask =
		UIViewAutoresizingFlexibleLeftMargin |
		UIViewAutoresizingFlexibleRightMargin |
		UIViewAutoresizingFlexibleTopMargin |
		UIViewAutoresizingFlexibleBottomMargin;
        
        [loadingView addSubview:loadingLabel];
        UIActivityIndicatorView *activityIndicatorView =
		[[UIActivityIndicatorView alloc]
         initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [loadingView addSubview:activityIndicatorView];
        activityIndicatorView.autoresizingMask =
		UIViewAutoresizingFlexibleLeftMargin |
		UIViewAutoresizingFlexibleRightMargin |
		UIViewAutoresizingFlexibleTopMargin |
		UIViewAutoresizingFlexibleBottomMargin;
        [activityIndicatorView startAnimating];
        
        CGFloat totalHeight =
		loadingLabel.frame.size.height +
		activityIndicatorView.frame.size.height;
        labelFrame.origin.x = floor(0.5 * (loadingView.frame.size.width - DEFAULT_LABEL_WIDTH));
        labelFrame.origin.y = floor(0.5 * (loadingView.frame.size.height - totalHeight));
        loadingLabel.frame = labelFrame;
        
        CGRect activityIndicatorRect = activityIndicatorView.frame;
        activityIndicatorRect.origin.x =
		0.5 * (loadingView.frame.size.width - activityIndicatorRect.size.width);
        activityIndicatorRect.origin.y = loadingLabel.frame.origin.y;
        activityIndicatorView.frame = activityIndicatorRect;
        
        //	changing the postion of label
        //	below activity indicator
        labelFrame.origin.y = activityIndicatorRect.size.height + activityIndicatorRect.origin.y;
        loadingLabel.frame = labelFrame;
    }
    else{
        loadingView.frame = aSuperview.bounds; 
        
        if(nil != loadingView.superview){
            [loadingView removeFromSuperview];
        }
        [aSuperview addSubview:loadingView];
    }
	
    [self setTitle:title];

	// Set up the fade-in animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
    animation.duration = 0.3f;
	[[aSuperview layer] addAnimation:animation forKey:@"layerAnimation"];
	
	return loadingView;
}

+ (void)removeView{
    if ([self isLoaded]) {
        [UIView animateWithDuration:0.3f animations:^{
            loadingView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [loadingView removeFromSuperview];
            loadingView=nil;
        }];
    }
 }

-(void)stop{
	[self removeFromSuperview];
 }
- (void)drawRect:(CGRect)rect
{
	const CGFloat ROUND_RECT_CORNER_RADIUS = 0.0;
	CGPathRef roundRectPath = New2PathWithRoundRect(rect, ROUND_RECT_CORNER_RADIUS);
	
	CGContextRef context = UIGraphicsGetCurrentContext();

	const CGFloat BACKGROUND_OPACITY = 0.65;
	CGContextSetRGBFillColor(context, 0, 0, 0, BACKGROUND_OPACITY);
	CGContextAddPath(context, roundRectPath);
	CGContextFillPath(context);

	const CGFloat STROKE_OPACITY = 0.25;
	CGContextSetRGBStrokeColor(context, 1, 1, 1, STROKE_OPACITY);
	CGContextStrokePath(context);
	
	CGPathRelease(roundRectPath);
}

+(BOOL)isLoaded{
    return loadingView ? YES : NO;
}
@end
