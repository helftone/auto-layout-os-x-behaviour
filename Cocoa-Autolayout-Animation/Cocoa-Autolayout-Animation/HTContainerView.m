//
//  HTContentViewView.m
//  Cocoa-Autolayout-Animation
//
//  Created by Milen Dzhumerov on 05/07/2014.
//  Copyright (c) 2014 Helftone. All rights reserved.
//

#import "HTContainerView.h"

@interface HTContainerView ()
@property(readwrite, strong, nonatomic) NSView* innerView;
@end

@implementation HTContainerView

-(void)containerViewInitialise {
	NSView* innerView = [[NSView alloc] init];
	// We will be adding our own constraints
	[innerView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self addSubview:innerView];
	
	// Center the inner view inside its superview.
	NSLayoutConstraint* centerX = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:innerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
	NSLayoutConstraint* centerY = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:innerView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
	[self addConstraints:@[centerX, centerY]];
	
	// Inner view will have a size of (50, 25)
	NSDictionary* viewMap = @{@"inner": innerView};
	[innerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[inner(50)]" options:0 metrics:nil views:viewMap]];
	[innerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[inner(25)]" options:0 metrics:nil views:viewMap]];
	
	self.innerView = innerView;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
	if((self = [super initWithCoder:aDecoder])) {
		[self containerViewInitialise];
	}
	
	return self;
}

-(instancetype)initWithFrame:(NSRect)frameRect {
	if((self = [super initWithFrame:frameRect])) {
		[self containerViewInitialise];
	}
	
	return self;
}

-(void)layout {
	[super layout];
	[self.delegate containerViewDidAutolayout:self];
}

@end
