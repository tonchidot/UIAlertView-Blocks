//
//  UIAlertView+Blocks.m
//  Shibui
//
//  Created by Jiva DeVoe on 12/28/10.
//  Copyright 2010 Random Ideas, LLC. All rights reserved.
//

#import "UIAlertView+Blocks.h"
#import <objc/runtime.h>

static CFStringRef RI_BUTTON_ASS_KEY = (CFStringRef)@"com.random-ideas.BUTTONS";

@implementation UIAlertView (Blocks)

-(id)initWithTitle:(NSString *)inTitle message:(NSString *)inMessage cancelButtonItem:(RIButtonItem *)inCancelButtonItem otherButtonItems:(RIButtonItem *)inOtherButtonItems, ... 
{
    if((self = [self initWithTitle:inTitle message:inMessage delegate:self cancelButtonTitle:inCancelButtonItem.label otherButtonTitles:nil]))
    {
        NSMutableArray *buttonsArray = [NSMutableArray array];
        
        RIButtonItem *eachItem;
        va_list argumentList;
        if (inOtherButtonItems)                     
        {                                  
            [buttonsArray addObject: inOtherButtonItems];
            va_start(argumentList, inOtherButtonItems);       
            while((eachItem = va_arg(argumentList, RIButtonItem *))) 
            {
                [buttonsArray addObject: eachItem];            
            }
            va_end(argumentList);
        }    
        
        for(RIButtonItem *item in buttonsArray)
        {
            [self addButtonWithTitle:item.label];
        }
        
        if(inCancelButtonItem)
            [buttonsArray insertObject:inCancelButtonItem atIndex:0];
        
        objc_setAssociatedObject(self, RI_BUTTON_ASS_KEY, buttonsArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [self setDelegate:self];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title 
			message:(NSString *)message 
  cancelButtonTitle:(NSString *)cancelButtonTitle 
	  okButtonTitle:(NSString *)okButtonTitle 
	   cancelAction:(void (^)(void))cancelAction 
		   okAction:(void (^)(void))okAction
{
	if((self = [self initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:okButtonTitle, nil]))
	{
		NSMutableArray *buttons = [NSMutableArray array];
        
		RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:cancelButtonTitle];
        cancelItem.action = cancelAction;
        RIButtonItem *okItem = [RIButtonItem itemWithLabel:okButtonTitle];
        okItem.action = okAction;
      
		[buttons addObject:cancelItem];
		[buttons addObject:okItem];
        
        objc_setAssociatedObject(self, RI_BUTTON_ASS_KEY, buttons, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [self setDelegate:self];
	}
	
	return self;
}

- (id)initWithTitle:(NSString *)title 
			message:(NSString *)message 
  cancelButtonTitle:(NSString *)cancelButtonTitle 
	   cancelAction:(void (^)(void))cancelAction 
{
	if((self = [self initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil]))
	{
		NSMutableArray *buttons = [NSMutableArray array];
        
		RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:cancelButtonTitle ];
        cancelItem.action = cancelAction;
		
		[buttons addObject:cancelItem];
        
        objc_setAssociatedObject(self, RI_BUTTON_ASS_KEY, buttons, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [self setDelegate:self];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSArray *buttonsArray = objc_getAssociatedObject(self, RI_BUTTON_ASS_KEY);
    RIButtonItem *item = [buttonsArray objectAtIndex:buttonIndex];
    if(item.action)
        item.action();
    objc_setAssociatedObject(self, RI_BUTTON_ASS_KEY, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
