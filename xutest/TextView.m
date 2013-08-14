/* Copyright © 1979-1999 Udanax.com. All rights reserved.

* This code is licensed under the terms of The Udanax Open-Source License, 
* which contains precisely the terms of the X11 License.  The full text of 
* The Udanax Open-Source License can be found in the distribution in the file 
* license.html.  If this file is absent, a copy can be found at 
* http://udanax.xanadu.com/license.html and http://www.udanax.com/license.html
*/
/*
**  TextView.m, implementation of scrolling text stuff for TextLab.
**  Copyright 1988 NeXT, Inc.  All Rights Reserved.
**  Author: Bruce Blumberg, NeXT Developer Support Group
*/

// Due the some bugs in the way Text object resizes after certain events
// (such as changing the font of a selection) the code below exhibits some
// strange behaviour. Most important is the scroll bar on the ScrollView ---
// it fails to change itself correctly on a window resize or setSelFont:.

#import <appkit/appkit.h>
#import "TextView.h"

extern int NXEditorFilter ();

@implementation TextView:ScrollView

+newFrame:(NXRect*)tFrame
{	id	tWin;
	
	/* create view */
	self = [super newFrame:tFrame];
	
	/* create enclosing window and set contentView */
	tWin = [Window newContent:tFrame style:NX_TITLEDSTYLE 
		backing:NX_BUFFERED buttonMask:NX_ALLBUTTONS defer:NO];
	[tWin setContentView:self];
	[tWin setBackgroundGray:NX_WHITE];
        [tWin setFreeWhenClosed:YES];
	
	/* specify scrollbars */
        [[self setVertScrollerRequired:YES] setHorizScrollerRequired:NO];

        {NXRect rect = bounds;
         [ScrollView getContentSize:&(rect.size) forFrameSize:&(tFrame->size)
	             horizScroller:NO vertScroller:YES borderType:NX_NOBORDER];
	 theText = [self newText:&rect];
	 [self setDocView:theText];
	
	 // You need to create a selection for the Text to be selected
	 // when you do "makeKeyWindow".

	 [theText setSel:0:0];

	 // The following two lines allow the resizing of the scrollview
	 // to be passed down to the docView (in this case, the text view 
	 // itself).

	 [contentView setAutoresizeSubviews:YES];
 	 [theText setAutosizing:NX_HEIGHTSIZABLE | NX_WIDTHSIZABLE];

        }

	/* display window and bring upfront */
	[window setTitle:"Untitled"];
	[window display];
	[window orderFront:self];
        [window makeKeyWindow];
	
	return(self);
}

// To get around Text strangeness. This code assures that on a resize
// the text is resized and redrawn correctly. 

- sizeTo:(float)w :(float)h 
{
  NXRect frm;
  NXSelPt start, end;

  [super sizeTo:w:h];
  [theText getSel:&start :&end];
  [theText getFrame:&frm];      
  [theText renewRuns:NULL text:NULL frame:&frm tag:0];
  [theText setSel:start.cp :end.cp];
  return self;
}

-newText:(NXRect *)tF
{
	id text = [Text newFrame:tF text:NULL alignment:NX_LEFTALIGNED];
	[[[[[text notifyAncestorWhenFrameChanged:YES]
		setVertResizable:YES]
		setHorizResizable:NO]
		setMonoFont:NO]
		setDelegate:self];
	{ NXSize aSize;
	  aSize.width = 0.0; aSize.height = tF->size.height;
	  [text setMinSize:&aSize];
	  aSize.width = tF->size.width; aSize.height = 1000000.;
	  [text setMaxSize:&aSize];
        }
	[text setCharFilter:NXEditorFilter];
	return text;
}

- setDocument:(tumbler*)docaddr
{
	thisdocument = *docaddr;
}
-(tumbler *)getDocument
{
	return &thisdocument;
}
-readXanadu
{
   spectype *specptr;
   char textarray[2000];
   	buildspec(&thisdocument,1,1000,&specptr);	
	grabspec(specptr,textarray);
	[theText setText:textarray];	
	
}
@end
	
 

