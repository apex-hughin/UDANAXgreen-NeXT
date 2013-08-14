/* Copyright � 1979-1999 Udanax.com. All rights reserved.

* This code is licensed under the terms of The Udanax Open-Source License, 
* which contains precisely the terms of the X11 License.  The full text of 
* The Udanax Open-Source License can be found in the distribution in the file 
* license.html.  If this file is absent, a copy can be found at 
* http://udanax.xanadu.com/license.html and http://www.udanax.com/license.html
*/

/* Generated by the NeXT Interface Builder */

#import <appkit/appkit.h>
#import <objc/Object.h>

@interface Controller : Object
{
    id	openReq;	// OpenPanel for open requests 
    id	saveReq;	// SavePanel for save-in requests
    id	fontReq;	// FontPanel for font requests
    id  archiver;
    id  errorText;	// TextField in error panel
}

- showError:(char *)errorMessage;
- setOpenReq:anObject;
- setSaveReq:anObject;
- setFontReq:anObject;
- setArchiver:anObject;
- setErrorText:anObject;
- newTextView:sender;
- openRequest:sender;
- printRequest:sender;
- saveInRequest:sender;
- saveRequest:sender;
- saveWindow:win inFile:(char *)name inDir:(char *)dirName;
- windowWillClose:(id)whichWin;
-startup;
@end
