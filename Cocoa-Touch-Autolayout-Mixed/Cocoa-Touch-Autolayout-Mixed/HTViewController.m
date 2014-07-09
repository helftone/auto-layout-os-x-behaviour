//
//  HTViewController.m
//  Cocoa-Touch-Autolayout-Mixed
//
//  Created by Milen Dzhumerov on 05/07/2014.
//  Copyright (c) 2014 Helftone. All rights reserved.
//

#import "HTViewController.h"
#import "HTContainerView.h"

// iOS allows mixed layout hierarchies. Launch the app and tap on "Autolayout Trace" - you will
// a print out of the view hierarchy and no ambiguous views. Try rotating the device or tapping
// on the left / right buttons to verify that the left, right and middle view are all correctly
// laid out by Auto Layout (as are the container subviews but they're not part of Auto Layout).

// Including the declaration means we can call the method without a compiler warning.
// NB: DO NOT ship production code with any calls to this method, it is for debugging purposes only.
@interface UIView (HTAutolayDebug)
-(NSString*)_autolayoutTrace;
@end

@interface HTViewController ()
@property(readwrite, strong, nonatomic) IBOutlet UIButton* topButton;
@end

@implementation HTViewController {
	NSLayoutConstraint* _leftWidth;
	NSLayoutConstraint* _rightWidth;
}

-(void)viewDidLoad {
	[super viewDidLoad];
	
	UIView* leftView = [[UIView alloc] init];
	leftView.backgroundColor = [UIColor purpleColor];
	// We will be adding constraints ourselves.
	leftView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:leftView];
	
	UIView* rightView = [[UIView alloc] init];
	rightView.backgroundColor = [UIColor purpleColor];
	rightView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:rightView];
	
	HTContainerView* containerView = [[HTContainerView alloc] init];
	containerView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:containerView];
	
	NSDictionary* viewMap = @{@"left": leftView, @"right" : rightView, @"button" : self.topButton, @"container" : containerView};
	
	// Left and right view go in the top-left and top-right corners, respectively. The container view
	// is squeezed inbetween.
	_leftWidth = [NSLayoutConstraint constraintWithItem:leftView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:75];
	NSLayoutConstraint* leftHeight = [NSLayoutConstraint constraintWithItem:leftView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50];
	[leftView addConstraints:@[_leftWidth, leftHeight]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[left]" options:0 metrics:nil views:viewMap]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[button]-[left]" options:0 metrics:nil views:viewMap]];
	
	_rightWidth = [NSLayoutConstraint constraintWithItem:rightView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:75];
	NSLayoutConstraint* rightHeight = [NSLayoutConstraint constraintWithItem:rightView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50];
	[rightView addConstraints:@[_rightWidth, rightHeight]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[right]-|" options:0 metrics:nil views:viewMap]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[button]-[right]" options:0 metrics:nil views:viewMap]];
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[left]-[container]-[right]" options:0 metrics:nil views:viewMap]];
	[containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[container(300)]" options:0 metrics:nil views:viewMap]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[button]-[container]" options:0 metrics:nil views:viewMap]];
	
	// Tapping on the left + right views just increases their width.
	UIGestureRecognizer* leftTapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftViewTapped:)];
	[leftView addGestureRecognizer:leftTapper];
	
	UIGestureRecognizer* rightTapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightViewTapped:)];
	[rightView addGestureRecognizer:rightTapper];
}

-(IBAction)autolayoutTraceTapped:(id)sender {
	NSLog(@"A start next to a view indicates that it is referenced by at least one constraint %@", [self.view.window _autolayoutTrace]);
}

-(void)leftViewTapped:(UIGestureRecognizer*)aRecognizer {
	if([aRecognizer state] == UIGestureRecognizerStateRecognized) {
		_leftWidth.constant += 10.0;
	}
}

-(void)rightViewTapped:(UIGestureRecognizer*)aRecognizer {
	if([aRecognizer state] == UIGestureRecognizerStateRecognized) {
		_rightWidth.constant += 10.0;
	}
}

@end
