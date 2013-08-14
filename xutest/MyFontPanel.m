/* Copyright © 1979-1999 Udanax.com. All rights reserved.

* This code is licensed under the terms of The Udanax Open-Source License, 
* which contains precisely the terms of the X11 License.  The full text of 
* The Udanax Open-Source License can be found in the distribution in the file 
* license.html.  If this file is absent, a copy can be found at 
* http://udanax.xanadu.com/license.html and http://www.udanax.com/license.html
*/
/*
**  MyFontPanel.m, a simple font panel (to be replaced by the real one in 0.9)
**  Copyright 1988 NeXT, Inc.  All Rights Reserved.
**  Author: Ali Ozer, NeXT Developer Support Group
*/

#import "MyFontPanel.h"

@implementation MyFontPanel

+ new
{
    self = [super new];
    [NXApp loadNibFile:"MyFontPanel.nib" owner:self];
    return self;
}

- setFontNameBox:anObject  {fontNameBox = anObject; return self;}

- setFontSizeBox:anObject  {fontSizeBox = anObject; return self;}

- setPanel:anObject {panel = anObject; return self;}

// doChange: is invoked when the user hits the "OK" button in the font panel.
// doChange sends a "setSelFont:" to the currently active text view. If no
// such textview exists, then the message isn't sent.

- doChange:sender
{
    id curWindow = [NXApp mainWindow];
    id font = [Font newFont:[[fontNameBox selectedCell] title]
		    size:atof([[fontSizeBox selectedCell] title])];

    if (curWindow && font) 
      [[curWindow firstResponder] tryToPerform:@selector(setSelFont:)
				  with:font];
    return self;
}

- orderFront:sender
{
    [panel orderFront:sender];
    return self;
}


@end
