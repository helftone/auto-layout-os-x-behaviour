//
//  HTAppDelegate.m
//  Cocoa-Autolayout-Animation
//
//  Created by Milen Dzhumerov on 05/07/2014.
//  Copyright (c) 2014 Helftone. All rights reserved.
//

#import "HTAppDelegate.h"
#import "HTContainerView.h"
#import <QuartzCore/QuartzCore.h>

// --- Movement Window ---
//
// Assuming that Method is "Set Layer Transform", input an angle and press Apply - the view will rotate.
// Now resize the window or click on the up / down arrow buttons. The view will lose its rotation as
// Auto Layout calls -setFrame: which ultimately resets the backing layer .transform property.
//
// Now, change the method to "Add Layer Animation" and re-apply an angle. Now resize or move the
// view - the rotation will not be lost. This is because we're applying it to the presentation layer
// which overwrites the model layer (which Auto Layout resets).

// --- Animation Window ---
//
// Experiment 1:
// - Set Method to "Set Layer Transform"
// - Turn on animation
// - Resize
//
// You will see that on every resize, Auto Layout overwrites the .transform property of the layer.
//
//
// Experiment 2:
// - Set Method to "Add Layer Animation"
// - Turn on animation
// - Resize or just wait until a graphical glitch appears
//
// While this method provides a partial workaround, graphical glitches do occur sometimes.
//
//
// Experiment 3:
// - Set Method to "Set Layer Transform"
// - Turn on "Re-apply transform"
// - Turn on animation
// - Resize
//
// We work around Auto Layout resetting the transform by just overwriting it afterwards. This
// only works because this is well-defined behaviour - NSView's implementation of -layout perform
// the actual setting of frames.

typedef NS_ENUM(NSInteger, HTMovementMethodTag) {
	HTMovementMethodTagSetLayerTransform = 1,
	HTMovementMethodTagAddLayerAnimation = 2,
};

@interface HTAppDelegate () <HTContainerViewDelegate>
@property(readwrite, strong, nonatomic) IBOutlet NSWindow* movementWindow;
@property(readwrite, strong, nonatomic) IBOutlet NSWindow* animationWindow;
@property(readwrite, assign, nonatomic) NSInteger movementAngle;
@property(readwrite, assign, nonatomic) HTMovementMethodTag movementMethodTag;
@property(readwrite, assign, nonatomic) HTMovementMethodTag animationMethodTag;
@property(readwrite, assign, nonatomic) BOOL reapplyAfterLayout;
@property(readwrite, strong, nonatomic) IBOutlet HTContainerView* containerView;
@end

@implementation HTAppDelegate {
	IBOutlet NSButton* _movementDebugButton;
	NSLayoutConstraint* _movementTopConstraint;
	NSView* _movementView;
	
	NSTimer* _animationTimer;
	CGFloat _animationRotation;
}

-(instancetype)init {
	if((self = [super init])) {
		self.movementMethodTag = HTMovementMethodTagSetLayerTransform;
		self.animationMethodTag = HTMovementMethodTagSetLayerTransform;
	}
	
	return self;
}

-(void)applicationDidFinishLaunching:(NSNotification*)aNotification {
	// Enable layer-backing for both windows
	[[[self animationWindow] contentView] setWantsLayer:YES];
	NSView* movementContentView = [[self movementWindow] contentView];
	[movementContentView setWantsLayer:YES];

	_movementView = [[NSView alloc] init];
	// We will be adding constraints ourselves
	[_movementView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[movementContentView addSubview:_movementView];
	CALayer* rotatingLayer = [_movementView layer];
	rotatingLayer.backgroundColor = [[NSColor redColor] CGColor];
	
	// Center along X axis and align with bottom side of "Show constraints" button
	NSLayoutConstraint* centerX = [NSLayoutConstraint constraintWithItem:movementContentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_movementView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
	_movementTopConstraint = [NSLayoutConstraint constraintWithItem:_movementView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_movementDebugButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:75];
	[movementContentView addConstraints:@[centerX, _movementTopConstraint]];
	
	// Size would be (50, 25)
	NSDictionary* viewMap = @{@"movement": _movementView};
	[_movementView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[movement(50)]" options:0 metrics:nil views:viewMap]];
	[_movementView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[movement(25)]" options:0 metrics:nil views:viewMap]];
	
	CALayer* innerLayer = [self.containerView.innerView layer];
	innerLayer.backgroundColor = [[NSColor redColor] CGColor];
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

-(CAAnimation*)infiniteAnimationForCATransform3D:(CATransform3D)aTransform {
	CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform"];
	// Setting fromValue == toValue effectively sets a constant value. Having an infinite animation
	// applying a constant value did not seem to have an impact on the CPU utilisation.
	anim.fromValue = [NSValue valueWithCATransform3D:aTransform];
	anim.toValue = [anim fromValue];
	anim.duration = HUGE_VALF;
	anim.repeatCount = HUGE_VALF;
	return anim;
}

#pragma mark - Movement

// Invoked by setValue:forKey: when it’s given a nil value for a scalar value.
-(void)setNilValueForKey:(NSString *)key {
	NSString* movementKey = @"movementAngle";
	if([key isEqual:movementKey]) {
		[self setValue:@(0) forKey:movementKey];
	}
	else {
		[super setNilValueForKey:key];
	}
}

-(IBAction)movementUpClicked:(id)aSender {
	_movementTopConstraint.constant -= 10.0;
}

-(IBAction)movementDownClicked:(id)aSender {
	_movementTopConstraint.constant += 10.0;
}

-(IBAction)movementApplyAngle:(id)sender {
	CATransform3D transform = CATransform3DIdentity;
	if([self movementAngle] != 0) {
		CGFloat radians = (M_PI / 180.0) * (CGFloat)[self movementAngle];
		transform = CATransform3DMakeRotation(radians, 0, 0, 1.0);
	}
	
	CALayer* layer = [_movementView layer];
	[layer removeAnimationForKey:@"transform"];
	
	switch ([self movementMethodTag]) {
		case HTMovementMethodTagSetLayerTransform: {
			[layer setTransform:transform];
			break;
		}
			
		case HTMovementMethodTagAddLayerAnimation: {
			[layer setTransform:CATransform3DIdentity];
			
			CAAnimation* animation = [self infiniteAnimationForCATransform3D:transform];
			[layer addAnimation:animation forKey:@"transform"];
			break;
		}
	}
}

#pragma mark - Animation

-(void)applyAnimationRotationTransform {
	CALayer* layer = [self.containerView.innerView layer];
	[layer removeAnimationForKey:@"transform"];
	
	CATransform3D transform = CATransform3DMakeRotation(_animationRotation, 0, 0, 1.0);
	switch ([self animationMethodTag]) {
		case HTMovementMethodTagSetLayerTransform: {
			[layer setTransform:transform];
			break;
		}
			
		case HTMovementMethodTagAddLayerAnimation: {
			[layer setTransform:CATransform3DIdentity];
			
			CAAnimation* animation = [self infiniteAnimationForCATransform3D:transform];
			[layer addAnimation:animation forKey:@"transform"];
			break;
		}
	}
}

-(void)animationTimerFired:(NSTimer*)aTimer {
	_animationRotation += (M_PI / 180.0) * 5.0;
	[self applyAnimationRotationTransform];
}

// CVDisplayLink can be used instead of an NSTimer but remember that the callback function
// is executed on an undefined thread / queue, thus you would want to hop onto the main queue
// to perform any UI related activities.
-(IBAction)toggleAnimationClicked:(id)sender {
	if(_animationTimer) {
		[_animationTimer invalidate];
		_animationTimer = nil;
	}
	else {
		// NB: This creates a retain cycle as timers retain their targets.
		_animationTimer = [NSTimer timerWithTimeInterval:(1.0 / 60.0) target:self selector:@selector(animationTimerFired:) userInfo:nil repeats:YES];
		// Using NSRunLoopCommonModes ensures the timer keeps firing if we're resizing the button etc.
		[[NSRunLoop mainRunLoop] addTimer:_animationTimer forMode:NSRunLoopCommonModes];
	}
}


#pragma mark - <HTContainerViewDelegate>

-(void)containerViewDidAutolayout:(id)aView {
	if([self reapplyAfterLayout]) {
		[self applyAnimationRotationTransform];
	}
}

@end
