/* Copyright © 1979-1999 Udanax.com. All rights reserved.

* This code is licensed under the terms of The Udanax Open-Source License, 
* which contains precisely the terms of the X11 License.  The full text of 
* The Udanax Open-Source License can be found in the distribution in the file 
* license.html.  If this file is absent, a copy can be found at 
* http://udanax.xanadu.com/license.html and http://www.udanax.com/license.html
*/
/*  Controller.m --- Main controller object for the TextLab program.
**  Copyright 1988 NeXT, Inc.  All Rights Reserved.
**  Authors: Bruce Blumberg and Ali Ozer, NeXT Developer Support Group
*/

// Controller object is the central object in TextLab.  It manages the
// windows, open/save panels, and menu commands. 

#import "Controller.h"
#import "TextView.h"
#import <sys/param.h>

@implementation Controller

// We subclass the Controller "new" so that we can set the application's
// delegate to point to the Controller object. This way open file
// requests from the Workspace get routed to the Controller's 
// appOpenFile:type: and appAcceptsAnotherFile methods.

+ new
{
  self = [super new];
  [NXApp setDelegate:self];
  return self;
}

// Allow Interface Builder objects to be connected to our outlets.

- setErrorText:anObject {errorText = anObject; return self;}
- setOpenReq:anObject   {openReq = anObject; return self;}
- setSaveReq:anObject   {saveReq = anObject; return self;}
- setFontReq:anObject   {fontReq = anObject; return self;}
- setArchiver:anObject  {archiver = anObject; return self;}

// error puts up a non-modal panel with the error message. 

- showError: (char *)errorMessage
{
  id errorPanel = [errorText window];
  [errorText setStringValue:errorMessage];
  [errorPanel orderFront:self];
  [errorPanel makeKeyWindow];
}

// newTextView: is invoked in response to a new empty window request. It
// creates a new window containing a TextView. Note that we want new windows 
// to be offset from each other by some amount; hence the use of wRect.

#define ORIGX 100.0
#define ORIGY 100.0
static NXRect wRect = {{ORIGX, ORIGY},{500.0,400.0}};

- newTextView:sender
{   
    id newTextView;
    NXOffsetRect(&wRect, 20.0, -20.0);
    if (wRect.origin.y < 0) {wRect.origin.y = ORIGY; wRect.origin.x = ORIGX;}
    newTextView = [TextView newFrame:&wRect];
    [[newTextView window] setDelegate:self];     
    return self;
}

// fontRequest puts up an instance of the Font Panel
-fontRequest:(id)sender
{
    [fontReq orderFront:sender];
    return self;
}

// appAcceptsAnotherFile is an application delegate method which 
// returns whether it is OK for the application to try to open more files
// with the appOpenFile:type: method. TextLab can indeed open multiple
// windows, so we return YES.

-(BOOL) appAcceptsAnotherFile:sender
{
  return (YES);
}

// appOpenFile:type: is called to open the specified file. It is normally
// called by the Application object in response to open requests from the
// Workspace. Here we also route the open requests from the OpenPanel
// to this method (see openRequest:).

-(int) appOpenFile:(char *)fileName type:(char *)fileType
{
   id win;

   if ([archiver open:fileName mode:NX_READONLY] == nil) 
	[self showError:"File not an archive file."];
   else {
	if (win = [archiver loadObjectWithRef:1]) {
	    [[win display] orderFront:self];
	    [win makeKeyWindow];
	} else [self showError:"File not a TextLab archive file."];
        [archiver close];
   }

   return YES;  
}

// CreateFullPath creates an absolute path name given a directory and file 
// name. Note that fullFileName should point to a string at least MAXPATHLEN+1
// characters long. (Defined in the include file <sys/param.h>.) If the file
// name already starts with a "/" (indicating an absolute path name) then
// it is simply returned as the full path name.

void CreateFullPath (fullFileName, dir, file) 
char *fullFileName, *dir, *file;
{
  if (file[0] == '/') strcpy (fullFileName, file);
  else {
    strcpy (fullFileName, dir);
    strcat (fullFileName, "/");
    strcat (fullFileName, file);
  }
}

// openRequest: opens a new file. It puts up a open panel, and, if the user
// doesn't cancel, it reads the specified archive file. If the selected file
// is not a proper archive file, then openRequest: will complain.

- openRequest:sender
{
    char *fileName, fullFileName[MAXPATHLEN+1], *types[] = {"tl", NULL};
    int ok;

    [openReq setDelegate:self];
    if ([openReq runModalForTypes:types] && ([openReq filename])) {
	CreateFullPath (fullFileName, [openReq dirPath], [openReq filename]);
	[NXApp openFile:fullFileName ok:&ok];
    }

    return self;
}

// Printing is rather simple; just send printPSCode: to the text view
// you wish to print. The print panel will automatically pop up and unless
// the user cancels the printout the text view will be printed.
//
// The code below reflects one bug workaround: If the text being printed
// has a highlighted selection, it will cause the printer to complain
// (as the printer cannot deal with "compositerect." Thus we first have to 
// make sure that the text object has nothing selected.

- printRequest:sender
{
    id curText = [[[NXApp mainWindow] contentView] docView];

    if (curText == nil) [self showError:"No active window to print."];
    else {
        NXSelPt start, end;  
        [curText getSel:&start :&end];
        [curText setSel:0 :0];         
	[[[NXApp printInfo] setHorizCentered:NO] setVertCentered:NO];
        [curText printPSCode:self];
	[curText setSel:start.cp :end.cp];
    }
    return self;
}

// closeRequest closes the current window by simulating a click on the
// closebutton. A check should probably be added to give the user the 
// option of saving the window before closing

- closeRequest:sender
{
   [[NXApp mainWindow] performClose:sender];
   return self;
}

// saveInRequest: gives the user a chance to save the current window
// under a new name. 

- saveInRequest:sender
{
#ifdef UndEfInEd
#endif
    return self;
}

// saveRequest: saves the current window under its default name (found in
// the title bar). Note that if the title bar is empty or the default title
// is "Untitled" then saveRequest: will put up a save panel, giving the user
// a chance to specify a real title.

- saveRequest:sender
{
    return self;

}

// saveWindowused to  write a window out the archive file whose name is specified
// by the second argument. The title of the current window is also set 
// accordingly. The extension of the file is also set to EXTENSION if not
// already so.

- saveWindow:win inFile:(char *)name inDir:(char *)dirName
{	
    return self;
}

// This method will get called before a window is closed and
- windowWillClose:(id)whichWin
{
    char *fileName;
      return self;
}
  
// load defaults
// for now from hardwire later from .frontendrc 
 
-startup
{
  id view;
 	view = [self newTextView:self];
	[view setDocument:&variabledocvposition];
	[view readXanadu];
}
  
    
@end
