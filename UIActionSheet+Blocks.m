//
//  UIActionSheet+Blocks.m
//  Shibui
//
//  Created by Jiva DeVoe on 1/5/11.
//  Copyright 2011 Random Ideas, LLC. All rights reserved.
//

#import "UIActionSheet+Blocks.h"
#import <objc/runtime.h>

static CFStringRef RI_BUTTON_ASS_KEY = (CFStringRef)@"com.random-ideas.BUTTONS";

@implementation UIActionSheet (Blocks)

-(id)initWithTitle:(NSString *)inTitle cancelButtonItem:(RIButtonItem *)inCancelButtonItem destructiveButtonItem:(RIButtonItem *)inDestructiveItem otherButtonItems:(RIButtonItem *)inOtherButtonItems, ...
{
    va_list otherButtonItems;
    va_start(otherButtonItems, inOtherButtonItems);
    va_end(otherButtonItems);
    return [self initWithTitle:inTitle cancelButtonItem:inOtherButtonItems destructiveButtonItem:inDestructiveItem otherFirstButtonItem:inOtherButtonItems otherButtonList:otherButtonItems];
}

-(id)initWithTitle:(NSString *)inTitle cancelButtonItem:(RIButtonItem *)inCancelButtonItem destructiveButtonItem:(RIButtonItem *)inDestructiveItem otherFirstButtonItem:(RIButtonItem *)inOtherFirstButtonItem otherButtonList:(va_list)inOtherButtonList;
{
    if((self = [self initWithTitle:inTitle delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil]))
    {
        NSMutableArray *buttonsArray = [NSMutableArray array];
        if (inOtherFirstButtonItem) [buttonsArray addObject:inOtherFirstButtonItem];
        RIButtonItem *eachItem;

        if (inOtherButtonList)
        {
            while((eachItem = va_arg(inOtherButtonList, RIButtonItem *)))
            {
                [buttonsArray addObject: eachItem];
            }
        }

        for(RIButtonItem *item in buttonsArray)
        {
            [self addButtonWithTitle:item.label];
        }

        if(inDestructiveItem)
        {
            [buttonsArray addObject:inDestructiveItem];
            NSInteger destIndex = [self addButtonWithTitle:inDestructiveItem.label];
            [self setDestructiveButtonIndex:destIndex];
        }
        if(inCancelButtonItem)
        {
            [buttonsArray addObject:inCancelButtonItem];
            NSInteger cancelIndex = [self addButtonWithTitle:inCancelButtonItem.label];
            [self setCancelButtonIndex:cancelIndex];
        }

        objc_setAssociatedObject(self, RI_BUTTON_ASS_KEY, buttonsArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    }
    return self;
}

- (NSInteger)addButtonItem:(RIButtonItem *)item
{	
    NSMutableArray *buttonsArray = objc_getAssociatedObject(self, RI_BUTTON_ASS_KEY);	
	
	NSInteger buttonIndex = [self addButtonWithTitle:item.label];
	[buttonsArray addObject:item];
	
	return buttonIndex;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != -1)
    {
        NSArray *buttonsArray = objc_getAssociatedObject(self, RI_BUTTON_ASS_KEY);
        RIButtonItem *item = [buttonsArray objectAtIndex:buttonIndex];
        if(item.action)
            item.action();
        objc_setAssociatedObject(self, RI_BUTTON_ASS_KEY, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
}


@end
