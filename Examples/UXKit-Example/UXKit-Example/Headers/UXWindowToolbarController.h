/*
    * This header is generated by classdump-dyld 1.0
    * on Friday, February 2, 2024 at 1:02:18 AM China Standard Time
    * Operating System: Version 14.2.1 (Build 23C71)
    * Image Source: /System/Library/PrivateFrameworks/UXKit.framework/Versions/A/UXKit
    * classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
    */

#import <Cocoa/Cocoa.h>

@class NSArray, NSDictionary, NSToolbar, UXNavigationItem, NSSearchToolbarItem, NSString;

@interface UXWindowToolbarController : NSObject <NSToolbarDelegate> {

	NSArray* _defaultItemIdentifiers;
	NSArray* _allowedItemIdentifiers;
	NSDictionary* _itemByIdentifier;
	NSToolbar* _toolbar;
	UXNavigationItem* _navigationItem;
	NSSearchToolbarItem* _searchToolbarItem;

}

@property (nonatomic, strong) UXNavigationItem *navigationItem;                    //@synthesize navigationItem=_navigationItem - In the implementation block
@property (nonatomic, strong) NSSearchToolbarItem *searchToolbarItem;              //@synthesize searchToolbarItem=_searchToolbarItem - In the implementation block
@property (nonatomic, readonly) NSToolbar *toolbar;                                //@synthesize toolbar=_toolbar - In the implementation block
@property (readonly) unsigned long long hash; 
@property (readonly) Class superclass; 
@property (copy, readonly) NSString *description; 
@property (copy, readonly) NSString *debugDescription; 
- (id)toolbar;
- (id)toolbar:(id)arg1 itemForItemIdentifier:(id)arg2 willBeInsertedIntoToolbar:(BOOL)arg3;
- (id)toolbarAllowedItemIdentifiers:(id)arg1;
- (id)toolbarDefaultItemIdentifiers:(id)arg1;
- (id)navigationItem;
- (void)setNavigationItem:(id)arg1;
- (id)initWithNavigationItem:(id)arg1;
- (void)_updateToolbarItems;
- (void)updateToolbar;
- (id)searchToolbarItem;
- (void)setSearchToolbarItem:(id)arg1;
@end

