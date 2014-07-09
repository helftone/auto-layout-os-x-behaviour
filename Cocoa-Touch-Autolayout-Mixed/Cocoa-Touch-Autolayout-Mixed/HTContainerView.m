//
//  HTContainerView.m
//  Cocoa-Touch-Autolayout-Mixed
//
//  Created by Milen Dzhumerov on 05/07/2014.
//  Copyright (c) 2014 Helftone. All rights reserved.
//

#import "HTContainerView.h"

// If HT_USE_AUTORESIZE_MASK is defined, then the subviews will be automatically laid out
// by the system using the autoresizing mask
//
//#define HT_USE_AUTORESIZE_MASK

@implementation HTContainerView {
	UIView* _leftView;
	UIView* _rightView;
}

-(instancetype)initWithFrame:(CGRect)frame {
#ifdef HT_USE_AUTORESIZE_MASK
	// Use a frame large enough to be able to layout the subviews
	frame = CGRectMake(0, 0, 500, 500);
#endif
	if((self = [super initWithFrame:frame])) {
		// Turn off autoresizing mask -> constraints conversion, as the views will either be manually
		// laid out in -layoutSubviews or by using the autoresizing mask.
		self.backgroundColor = [UIColor yellowColor];
		_leftView = [[UIView alloc] init];
		_leftView.backgroundColor = [UIColor redColor];
		_leftView.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:_leftView];
		_rightView = [[UIView alloc] init];
		_rightView.backgroundColor = [UIColor redColor];
		_rightView.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:_rightView];
		
#ifdef HT_USE_AUTORESIZE_MASK
		[self layoutLeftRightViews];
		self.autoresizesSubviews = YES;
		_leftView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
		_rightView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
#endif
	}
	
	return self;
}

-(void)layoutLeftRightViews {
	static const CGFloat HTSubviewLength = 50.0;
	static const CGFloat HTSubviewOffset = 10.0;
	
	CGRect bounds = [self bounds];
	CGRect remainder, leftFrame, rightFrame;
	CGRectDivide(bounds, &leftFrame, &remainder, HTSubviewLength, CGRectMinXEdge);
	CGRectDivide(leftFrame, &leftFrame, &remainder, HTSubviewLength, CGRectMinYEdge);
	CGRectDivide(bounds, &rightFrame, &remainder, HTSubviewLength, CGRectMaxXEdge);
	CGRectDivide(rightFrame, &rightFrame, &remainder, HTSubviewLength, CGRectMinYEdge);
	leftFrame.origin.x += HTSubviewOffset, leftFrame.origin.y += HTSubviewOffset;
	rightFrame.origin.x -= HTSubviewOffset, rightFrame.origin.y += HTSubviewOffset;
	
	_leftView.frame = leftFrame;
	_rightView.frame = rightFrame;
}

-(void)layoutSubviews {
	[super layoutSubviews];
#ifndef HT_USE_AUTORESIZE_MASK
	[self layoutLeftRightViews];
#endif
}

@end
