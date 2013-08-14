/* Copyright © 1979-1999 Udanax.com. All rights reserved.

* This code is licensed under the terms of The Udanax Open-Source License, 
* which contains precisely the terms of the X11 License.  The full text of 
* The Udanax Open-Source License can be found in the distribution in the file 
* license.html.  If this file is absent, a copy can be found at 
* http://udanax.xanadu.com/license.html and http://www.udanax.com/license.html
*/

#import <appkit/ScrollView.h>
#import <appkit/Text.h>


@interface TextView:ScrollView 
{
	id	theText;
	id fromFont, toFont;
	tumbler thisdocument;
	int documentlength;
}

//+newFrame:(NXRect *)tFrame;
+newFrame:(NXRect const *)tFrame;
-newText:(NXRect *)tF;
-setDocument:(tumbler*)docaddr;
-readXanadu;
-displayLinks;
-(bool)followlink:curTextView;
-jumpToJumpLink:(tumbler*)docvsaptr;
- findspecfromselection:(spectype **)specptr;
- (tumbler *)getDocument;
@end


