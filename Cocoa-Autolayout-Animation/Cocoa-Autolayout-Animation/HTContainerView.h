//
//  HTContentViewView.h
//  Cocoa-Autolayout-Animation
//
//  Created by Milen Dzhumerov on 05/07/2014.
//  Copyright (c) 2014 Helftone. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol HTContainerViewDelegate <NSObject>
-(void)containerViewDidAutolayout:(id)aView;
@end

@interface HTContainerView : NSView

@property(readwrite, weak, nonatomic) IBOutlet id<HTContainerViewDelegate> delegate;
@property(readonly, strong, nonatomic) NSView* innerView;

@end
