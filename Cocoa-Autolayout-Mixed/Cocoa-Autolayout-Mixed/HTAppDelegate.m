//
//  HTAppDelegate.m
//  Cocoa-Autolayout-Mixed
//
//  Created by Milen Dzhumerov on 05/07/2014.
//  Copyright (c) 2014 Helftone. All rights reserved.
//

#import "HTAppDelegate.h"
#import "HTContainerView.h"

// In this sample, we create a container view that is laid out by Auto Layout which in turn contains
// subviews that are not and lie completely outside the scope of Auto Layout (there are no constraints
// that reference them). Even though the layout will get flagged as ambiguous, it actually is not.
//
// In order to reproduce the issues, perform the following:
// 1) Turn on "Show constraints". Note that the layout will not be deemed ambiguous.
// 2) Turn on "Container subviews". Now, the layout will be deemed ambiguous. Try clickg on
//    "Exercise Ambiguity" - nothing will happen. You can try resizing the window and everything
//    will be laid out correctly.

@implementation HTAppDelegate {
	NSLayoutConstraint* _leftWidth;
	NSLayoutConstraint* _rightWidth;
	IBOutlet NSButton* _debugButton;
	IBOutlet NSButton* _containerSubviewsButton;
}

-(void)applicationDidFinishLaunching:(NSNotification*)aNotification {
	// Enable layer-backing for the view hierarchy
	NSView* contentView = [self.window contentView];
	[[self.window contentView] setWantsLayer:YES];
	
	NSView* leftView = [[NSView alloc] init];
	// We will be adding our own constraints
	leftView.translatesAutoresizingMaskIntoConstraints = NO;
	[contentView addSubview:leftView];
	[[leftView layer] setBackgroundColor:[[NSColor purpleColor] CGColor]];
	
	NSView* rightView = [[NSView alloc] init];
	rightView.translatesAutoresizingMaskIntoConstraints = NO;
	[contentView addSubview:rightView];
	[[rightView layer] setBackgroundColor:[[NSColor purpleColor] CGColor]];
	
	HTContainerView* containerView = [[HTContainerView alloc] init];
	containerView.translatesAutoresizingMaskIntoConstraints = NO;
	[contentView addSubview:containerView];
	[_containerSubviewsButton setTarget:containerView];
	[_containerSubviewsButton setAction:@selector(addContainerSubviewsClicked:)];
	
	NSDictionary* viewMap = @{@"left": leftView, @"right" : rightView, @"container" : containerView, @"debug": _debugButton};
	
	// left view go in the top left corner
	_leftWidth = [NSLayoutConstraint constraintWithItem:leftView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:75];
	NSLayoutConstraint* leftHeight = [NSLayoutConstraint constraintWithItem:leftView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50];
	[leftView addConstraints:@[_leftWidth, leftHeight]];
	[contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[left]" options:0 metrics:nil views:viewMap]];
	[contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[left]" options:0 metrics:nil views:viewMap]];
	
	// right view goes in the top right corner
	_rightWidth = [NSLayoutConstraint constraintWithItem:rightView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:75];
	NSLayoutConstraint* rightHeight = [NSLayoutConstraint constraintWithItem:rightView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50];
	[rightView addConstraints:@[_rightWidth, rightHeight]];
	[contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[right]-|" options:0 metrics:nil views:viewMap]];
	[contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[right]" options:0 metrics:nil views:viewMap]];
	
	// container gets squeezed inbetween the left and right views (along X) and between the top of the window and the debug button (along Y)
	[contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[left]-[container]-[right]" options:0 metrics:nil views:viewMap]];
	[contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[container]-[debug]" options:0 metrics:nil views:viewMap]];
}

-(IBAction)showConstraintsClicked:(NSButton*)aSender {
	NSMutableArray* constraints = [NSMutableArray array];
	if([aSender state] == NSOnState) {
		NSMutableArray* views = [NSMutableArray arrayWithObject:[[aSender window] contentView]];
		
		while ([views count] > 0) {
			NSView* view = [views objectAtIndex:0];
			[views removeObjectAtIndex:0];
			[views addObjectsFromArray:[view subviews]];
			
			if([view hasAmbiguousLayout]) {
				NSLog(@"View has ambiguous layout=%@", view);
			}
			
			[constraints addObjectsFromArray:[view constraints]];
		}
	}
	
	[[aSender window] visualizeConstraints:constraints];
}

-(IBAction)increaseLeftClicked:(id)sender {
	_leftWidth.constant += 10.0;
}

-(IBAction)increaseRightClicked:(id)sender {
	_rightWidth.constant += 10.0;
}

@end
