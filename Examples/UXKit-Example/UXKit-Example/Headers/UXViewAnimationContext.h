/*
    * This header is generated by classdump-dyld 1.0
    * on Friday, February 2, 2024 at 1:02:18 AM China Standard Time
    * Operating System: Version 14.2.1 (Build 23C71)
    * Image Source: /System/Library/PrivateFrameworks/UXKit.framework/Versions/A/UXKit
    * classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
    */

#import <Foundation/Foundation.h>
@interface UXViewAnimationContext : NSObject {

	double _mass;
	double _stiffness;
	double _damping;
	double _velocity;

}

@property (nonatomic) double mass;                   //@synthesize mass=_mass - In the implementation block
@property (nonatomic) double stiffness;              //@synthesize stiffness=_stiffness - In the implementation block
@property (nonatomic) double damping;                //@synthesize damping=_damping - In the implementation block
@property (nonatomic) double velocity;               //@synthesize velocity=_velocity - In the implementation block
- (double)damping;
- (double)mass;
- (void)setDamping:(double)arg1;
- (void)setMass:(double)arg1;
- (void)setStiffness:(double)arg1;
- (void)setVelocity:(double)arg1;
- (double)stiffness;
- (double)velocity;
- (void)generateSpringPropertiesForDuration:(double)arg1 damping:(double)arg2 velocity:(double)arg3;
@end
