//
//  HTContainerView.m
//  Cocoa-Autolayout-Mixed
//
//  Created by Milen Dzhumerov on 06/07/2014.
//  Copyright (c) 2014 Helftone. All rights reserved.
//

#import "HTContainerView.h"

@implementation HTContainerView {
	NSView* _leftView;
	NSView* _rightView;
}

-(instancetype)initWithFrame:(NSRect)frameRect {
	if((self = [super initWithFrame:frameRect])) {
		// We need to turn on layer-backing before we call -layer, otherwise it will be nil
		[self setWantsLayer:YES];
		[[self layer] setBackgroundColor:[[NSColor yellowColor] CGColor]];
	}
	
	return self;
}

-(void)layout {
	[super layout];
	
	// Position the left view in the top-left corner and the right view in the top-right corner
	CGRect bounds = [self bounds];
	CGRect remainder, leftFrame, rightFrame;
	CGRectDivide(bounds, &leftFrame, &remainder, 50, CGRectMinXEdge);
	CGRectDivide(leftFrame, &leftFrame, &remainder, 50, CGRectMaxYEdge);
	CGRectDivide(bounds, &rightFrame, &remainder, 50, CGRectMaxXEdge);
	CGRectDivide(rightFrame, &rightFrame, &remainder, 50, CGRectMaxYEdge);
	leftFrame.origin.x += 10.0, leftFrame.origin.y -= 10.0;
	rightFrame.origin.x -= 10.0, rightFrame.origin.y -= 10.0;
	
	_leftView.frame = leftFrame;
	_rightView.frame = rightFrame;
}

-(IBAction)addContainerSubviewsClicked:(NSButton*)aSender {
	if([aSender state] == NSOnState) {
		if(_leftView == nil) {
			_leftView = [[NSView alloc] init];
			// We'll be laying out the view manually in -layout, so prevent the system from
			// adding any constraints (so that the view lies outside the scope of Auto Layout)
			_leftView.translatesAutoresizingMaskIntoConstraints = NO;
			[self addSubview:_leftView];
			[[_leftView layer] setBackgroundColor:[[NSColor redColor] CGColor]];
		}
		
		if(_rightView == nil) {
			_rightView = [[NSView alloc] init];
			_rightView.translatesAutoresizingMaskIntoConstraints = NO;
			[self addSubview:_rightView];
			[[_rightView layer] setBackgroundColor:[[NSColor redColor] CGColor]];
		}
		
		[self setNeedsLayout:YES];
	}
	else {
		[_leftView removeFromSuperview];
		_leftView = nil;
		[_rightView removeFromSuperview];
		_rightView = nil;
	}
}

@end
