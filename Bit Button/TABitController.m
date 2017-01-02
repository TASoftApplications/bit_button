//
//  TABitController.m
//  Bit Button
//
//  Created by Thomas Abplanalp on 02.01.17.
//  Copyright (c) 2017 TASoft Applications. All rights reserved.
//

#import "TABitController.h"

#define _TABitValueKeyPath @"cell.state"

@interface NSObject (TAPrivate)
- (NSArray *)_binders;
@end

@implementation TABitController {
	BOOL _updatingButtons;
}

- (NSArray *)buttonKeyPaths {
	return @[@"button1", @"button2", @"button3", @"button4", @"button5", @"button6", @"button7", @"button8", @"button9", @"button10"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		for(NSString *kp in [self buttonKeyPaths])
			[self addObserver:self forKeyPath:kp options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionPrior context:NULL];
	}
	return self;
}

- (void)dealloc
{
	for(NSString *kp in [self buttonKeyPaths])
		[self removeObserver:self forKeyPath:kp];
}

- (void)fireBinding {
	NSDictionary *info = [self infoForBinding:NSContentObjectBinding];
	
	id obj = [info valueForKey:NSObservedObjectKey];
	NSString *kp = [info valueForKey:NSObservedKeyPathKey];
	NSValueTransformer *trans = [[info objectForKey:NSOptionsKey] objectForKey:NSValueTransformerBindingOption];
	
	NSNumber *me = self.content;
	if([trans isKindOfClass:[NSValueTransformer class]])
		me = [trans reverseTransformedValue:me];
	
	[obj setValue:me forKeyPath:kp];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if([keyPath isEqualToString:_TABitValueKeyPath]) {
		if(_updatingButtons)
			return;
		
		
		NSInteger state = [(NSButton *)object state];
		if(state < 0) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[(NSButton *)object setState:1];
			});
			return;
		}
		
		NSUInteger options = [self.content unsignedIntegerValue];
		NSInteger tag = [object tag];
		if(state == 1) {
			options |= tag;
		} else {
			options &= ~tag;
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			NSUInteger opts = [self.content unsignedIntegerValue];
			
			if(opts != options) {
				[self setContent:@(options)];
				[self fireBinding];
			}
		});
		return;
	}
	NSButton *old = [change valueForKey:NSKeyValueChangeOldKey];
	NSButton *new = [self valueForKey:keyPath];
	
	if([old isKindOfClass:[NSButton class]]) {
		[old removeObserver:self forKeyPath:_TABitValueKeyPath];
	}
	
	if([new isKindOfClass:[NSButton class]]) {
		[new addObserver:self forKeyPath:_TABitValueKeyPath options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
	}
}

- (void)setContent:(id)content {
	NSAssert([content isKindOfClass:[NSNumber class]], @"Bit Controller needs a NSNumber object as content.");
	
	NSUInteger oldOptions = [self.content unsignedIntegerValue];
	[super setContent:content];
	NSUInteger options = [self.content unsignedIntegerValue];
	
	
	if(oldOptions != options) {
		_updatingButtons = YES;
		for(NSString *kp in [self buttonKeyPaths]) {
			NSButton *bt = [self valueForKey:kp];
			if(bt) {
				NSInteger tag = bt .tag;
				if(bt.allowsMixedState) {
					if((options & tag) == tag)
						bt.state = NSOnState;
					else if (options & tag)
						bt.state = NSMixedState;
					else
						bt.state = NSOffState;
				} else {
					if(options & tag)
						bt.state = NSOnState;
					else
						bt.state = NSOffState;
				}
			}
		}
		_updatingButtons = NO;
	}
}
@end
