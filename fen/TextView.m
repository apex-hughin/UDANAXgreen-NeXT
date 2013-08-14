/* Copyright © 1979-1999 Udanax.com. All rights reserved.

* This code is licensed under the terms of The Udanax Open-Source License, 
* which contains precisely the terms of the X11 License.  The full text of 
* The Udanax Open-Source License can be found in the distribution in the file 
* license.html.  If this file is absent, a copy can be found at 
* http://udanax.xanadu.com/license.html and http://www.udanax.com/license.html
*/
/*
**  TextView.m, implementation ofn scrolling text stuff for TextLab.
**  Copyright 1988 NeXT, Inc.  All Rights Reserved.
**  Author: Bruce Blumberg, NeXT Developer Support Group
*/

// Due the some bugs in the way Text object resizes after certain events
// (such as changing the font of a selection) the code below exhibits some
// strange behaviour. Most important is the scroll bar on the ScrollView ---
// it fails to change itself correctly on a window resize or setSelFont:.
#include "fest.h"
#import <appkit/appkit.h>
#import "TextView.h"

//extern int NXEditorFilter ();

@implementation TextView:ScrollView

+newFrame:(NXRect const*)tFrame
{	id	tWin;
	id 	defaultFont;	
	float size;
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
//	 [theText setDelegate:self];
	
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

  defaultFont = [Text getDefaultFont];
	size = [defaultFont pointSize];
  fromFont = [Font newFont :"Courier-Bold" size :size];
  toFont =   [Font newFont :"Times-Bold" size:size];
	
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
-displayLinks
{
  spectype *specptr = NULL;
  spectype *fromset=NULL,*toset= NULL;
  spantype * span= NULL;
  
	buildspec(&thisdocument,1,documentlength,&specptr);
	findendsetsinspec(specptr,&fromset,&toset);
	if(fromset){
	for(span=fromset->specspanptr;span!=NULL;span = span->nextspan){


	[theText setSel  :max(0,span->vstartaddress.smallmantissa[1]-1)
	      :span->vstartaddress.smallmantissa[1]+span->sizeofspan];
		[theText setSelFont: fromFont];

	}
	}
	if(toset){
	for(span=(toset)->specspanptr;span!=NULL;span = span->nextspan){
		[theText setSel:span->vstartaddress.smallmantissa[1]-1
		:span->vstartaddress.smallmantissa[1]+span->sizeofspan];
		[theText setSelFont: toFont];
	}
	}
	specfree(specptr);
	specfree(fromset);
	specfree(toset);
}


-readXanadu
{
   spectype *specptr = NULL;
   char *textarray;
     int temp;
      buildspec(&thisdocument,1,temp=retrievetextsize(&thisdocument),&specptr);
	documentlength = temp;
	textarray = alloc(documentlength);
	grabspec(specptr,textarray);
	[theText setText:textarray];
	[self displayLinks];
	specfree(specptr);	
}

-jumpToJumpLink :(tumbler*)docvsaptr
{
  spectype *specptr = NULL;
   char *textarray;
     int temp;
	specptr = specalloc();
	copyvpositionintospec(docvsaptr,specptr);
	specptr->specspanptr->vstartaddress.smallmantissa[1]=0; // zzz
	temp = retrievetextsize(&(specptr->docid));
        specptr->specspanptr->sizeofspan=documentlength = temp;
        textarray = alloc(documentlength);
        grabspec(specptr,textarray);
        [theText setText:textarray];
	[self setDocument:&(specptr->docid)];
        [self displayLinks];
        specfree(specptr);

}


  static tumbler link;
-(bool)followlink:(id)curTextView
{
  med whichend;
  med linktype;
void findcorrectlink();
void actuallyfollowlink();
        if(!curTextView){
                return FALSE;
        }
        memclear ((char *)&link,sizeof(tumbler));
        findcorrectlink (curTextView,&link, &whichend);
        if (iszerotumbler (&link)) {
                return FALSE;
        }
        findlinktype (&link, &linktype);
        actuallyfollowlink (self,&link, whichend, linktype);
        return TRUE;
}
static tasktype task;  
  void
findcorrectlink(textview,linkidptr, whichendtojumpto)
  id textview;
  tumbler *linkidptr;
  med *whichendtojumpto;
{
void interactendset();
void interactlinkset();

  tumbleritemtype *linkset;
        findlinkset (textview,&task, &linkset, whichendtojumpto);
        if(!linkidptr) fprintf(stderr,"Null linkidptr in findcorrectlink\n");
        interactlinkset (linkset, linkidptr, *whichendtojumpto);
}

  void
findlinkset (textview,taskptr, linksetptr, whichendtojumpto)
  id textview;
  tasktype *taskptr;
  tumbleritemtype **linksetptr;
  med *whichendtojumpto;
{
  spectype *specptr, *specalloc();
  void findspecfromselection();

        specptr = NULL;
        [textview findspecfromselection: &specptr];
        specptr->specspanptr->sizeofspan = 1;
        retrievelinksetfrombackend (taskptr, specptr, FROM, linksetptr);
        if (*linksetptr) {
                *whichendtojumpto = TO;
        } else {
                retrievelinksetfrombackend (taskptr, specptr, TO, linksetptr);
                *whichendtojumpto = FROM;
                /*if(!*linksetptr)gerror ("Null linkset in findlinkset");this is the no link case */
        }
        specfree (specptr);
}

static  tumbleritemtype *linkset;
static  tumbler *linkidptr;
static  med listsize;
static  tumbleritemtype *linkitem;
static  char **linklist;
static  med whichendtojumpto;


  void
interactlinkset (paramlinkset, paramlinkidptr, paramwhichendtojumpto)
  tumbleritemtype *paramlinkset;
  tumbler *paramlinkidptr;
  med paramwhichendtojumpto;
{
  med linkindex;
        linkset = paramlinkset;
        linkidptr = paramlinkidptr;
        whichendtojumpto = paramwhichendtojumpto;

        if (!linkset)
                return;

        if(!linkidptr)fprintf(stderr," Null linkidptr in interactlinkset");
#ifdef UnDeFinEd
        listsize = makelistforlinkmenu (linkset, &linklist, whichendtojumpto);
        if(listsize > 1){

/*                if(iswindow){
                        makemenu(linklist,LINKMENUCHOICE0,listsize,"choose link");
                        return;
                }
                linkindex = selectmenu (currentwindow->rcursl, currentwindow->rcursc, listsize, linklist);
                interactlinkset2(linkindex);
        }else{
*/
#endif
                linkitem = linkset;
                movetumbler (&linkitem->value, linkidptr);


/*        }*/

        tfree (&task.tempspace);
}


- findspecfromselection:(spectype **)specsetptr
{
  long disp;
  NXSelPt start, end;
	[theText getSel: &start: &end];
	disp = start.cp;
	buildspec([self getDocument],disp,start.cp-end.cp,specsetptr);
}

  void
actuallyfollowlink (textview,linkidptr, whichend, linktype)
  id textview;
  tumbler *linkidptr;
  med whichend;
  med linktype;
{
  tumbler docvsa;
  spectype *endset;
  void finddocvsatojumpto();
        /*freeupcurrentwindowslinkset ();*/
/*        switch (linktype) {

        case JUMPLINK:
*/
                finddocvsatojumpto (linkidptr, whichend, &docvsa);
                [textview jumpToJumpLink:&docvsa];
/*                break;
          case QUOTELINK:
          case FOOTNOTELINK:
                finddocvsatojumpto (linkidptr, whichend, &docvsa);
                if( whichend == TO){
                        jumptofootnotelink (&docvsa);
                }else{
                        jumptojumplink (&docvsa);
                }
                break;
          case MARGINALNOTELINK:
                finddocvsatojumpto (linkidptr, whichend, &docvsa);
                if( whichend == TO){
                        jumptomarginalnotelink (&docvsa);
                }else{
                        jumptojumplink (&docvsa);
                }
                break;

        }
*/
}


  void
finddocvsatojumpto (linkidptr, whichend, docvsaptr)
  tumbler *linkidptr, *docvsaptr;
  med whichend;
{
  spectype *specptr;
  tasktype task;
void interactendset();
        retrieveendsetfrombackend (&task, linkidptr, whichend, &specptr);
        interactendset (specptr, docvsaptr);
        tfree (&task.tempspace);
}


  void
interactendset (specptr, docvsaptr)
  spectype *specptr;
  tumbler *docvsaptr;
{                        /* for now, take first vspan of first spec */
/*  tumbler vhead, vtail;
*/
if(!specptr){
        gerror("interactendset called with null specptr");
}
        /*fprintf(stderr,"%d",specptr->specspanptr->sizeofspan);*/
        makedocvsa (&specptr->docid,&specptr->specspanptr->vstartaddress, docvsaptr);
}

@end
	
 

