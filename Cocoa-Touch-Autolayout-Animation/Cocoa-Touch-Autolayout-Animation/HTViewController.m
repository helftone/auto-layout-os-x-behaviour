//
//  HTViewController.m
//  Cocoa-Touch-Autolayout-Animation
//
//  Created by Milen Dzhumerov on 05/07/2014.
//  Copyright (c) 2014 Helftone. All rights reserved.
//

#import "HTViewController.h"

// This sample shows that Auto Layout does not overwrite CALayer's transform property. To verify:
// - Turn on the animation
// - Optionally, you can turn it off with the view at a particular angle or you can leave the animation running
// - Rotate the device: the rotating view will not get its .transform reset
// - You can tap anywhere in the empty space to offset it a bit: again, the transform does not get reset
//
// To verify that the view is being laid out by Auto Layout, tap on "Autolayout Trace" and note that
// the rotating view has a star next to it.

// Including the declaration means we can call the method without a compiler warning.
// NB: DO NOT ship production code with any calls to this method, it is for debugging purposes only.
@interface UIWindow (HTAutolayoutDebug)
-(NSString*)_autolayoutTrace;
@end

@interface HTViewController ()
@property(readwrite, strong, nonatomic) IBOutlet UIButton* button;
@end

@implementation HTViewController {
	NSLayoutConstraint* _yConstraint;
	UIView* _rotatingView;
	CGFloat _rotation;
	
	CADisplayLink* _displayLink;
}

-(void)tappedOnView:(UIGestureRecognizer*)aRecognizer {
	if([aRecognizer state] == UIGestureRecognizerStateRecognized) {
		_yConstraint.constant += 5.0;
	}
}

-(void)viewDidLoad {
	[super viewDidLoad];
	
	_rotatingView = [[UIView alloc] init];
	// We will be adding constraints ourselves.
	[_rotatingView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self.view addSubview:_rotatingView];
	[_rotatingView setBackgroundColor:[UIColor redColor]];
	
	// Center the rotating view.
	NSDictionary* viewMap = @{@"rotating": _rotatingView, @"button": self.button};
	NSLayoutConstraint* xConstraint = [NSLayoutConstraint constraintWithItem:[self view] attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_rotatingView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
	_yConstraint = [NSLayoutConstraint constraintWithItem:[self view] attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_rotatingView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
	[self.view addConstraints:@[xConstraint, _yConstraint]];
	[_rotatingView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[rotating(100)]" options:0 metrics:nil views:viewMap]];
	[_rotatingView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[rotating(25)]" options:0 metrics:nil views:viewMap]];
	
	// Offset the rotating view on each tap.
	UIGestureRecognizer* tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnView:)];
	[self.view addGestureRecognizer:tapper];
}

-(void)displayLinkDidTick:(CADisplayLink*)aDisplayLink {
	_rotation += (M_PI / 180.0) * 5.0;
	_rotatingView.transform = CGAffineTransformMakeRotation(_rotation);
}

-(IBAction)toggleAnimationTapped:(id)sender {
	if(_displayLink == nil) {
		// NB: CADisplayLink retains its target, so we have created a retain cycle. DO NOT ship
		//     production code based on this sample code.
		_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkDidTick:)];
		[_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
	}
	else {
		[_displayLink invalidate];
		_displayLink = nil;
	}
}

-(IBAction)autolayoutTraceTapped:(id)sender {
	NSLog(@"A start next to a view indicates that it is referenced by at least one constraint %@", [self.view.window _autolayoutTrace]);
}

@end
