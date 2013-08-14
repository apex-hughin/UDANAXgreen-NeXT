/* Copyright © 1979-1999 Udanax.com. All rights reserved.

* This code is licensed under the terms of The Udanax Open-Source License, 
* which contains precisely the terms of the X11 License.  The full text of 
* The Udanax Open-Source License can be found in the distribution in the file 
* license.html.  If this file is absent, a copy can be found at 
* http://udanax.xanadu.com/license.html and http://www.udanax.com/license.html
*/

#define  NOSUNWINDOWS

#include "fest.h"
#import "Controller.h"
#define RCFILENAME               ".frontendrc"
#define RCBAKFILENAME               ".frontendrc.bak"

#define STARTDOCUMENTTUMBLER	"startdocumenttumbler"	
#define HOMEDOCUMENTTUMBLER	"homedocumenttumbler"	

/* Read run-time parameters from ./.backendrc    ECH 7-7-88
   This is real dumb, but it should be enough to get the job done for now.
*/
int timetoquit = FALSE;
static struct queue *homequeue;
static struct queue *startqueue;
static void localrename();
static void torcfile(  struct queue *q,  char * type);
 void savehomestorcfile();
 void savepositionstorcfile();

bool scantum(char *s,tumbler *t);
void editum(tumbler *t,char *s);
void processrcfile(sender)
  id sender;
{
  FILE *rcfd;
  static char buf[BUFSIZ];
  static char line[256];
  static char name[256];
 tumbler t;
int i;
int numberofwindows = 0;
int start;
struct iqte *iq;
  homequeue = (struct queue *)alloc(sizeof(struct queue));
  qinit(homequeue);
  startqueue = (struct queue *)alloc(sizeof(struct queue));
  qinit(startqueue);
  if ((rcfd = fopen(RCFILENAME, "r")) != NULL) {
    while (fgets(buf, BUFSIZ, rcfd)) {
      if (buf[0] != '#' && sscanf(buf, "%s = %s ~ %d ~", name, line, &start) == 3) {
        if (!strcmp(name, STARTDOCUMENTTUMBLER)){
	   if(*line){
		 i=scantum(line,&t);
	   }
	   assert(i);
/*	   opendoc(rootframe, NULL, &t, start, 1, OMREAD_ONLY, OMCONF_COPY);*/
	   [sender opendoc :&t :start];
	   numberofwindows++;
        }else if (!strcmp(name, HOMEDOCUMENTTUMBLER)){
	   if(*line){
		 i=scantum(line,&t);
	   }
	   assert(i);
	   iq = (struct iqte *)alloc(sizeof( struct iqte));
	   tumblercopy(&t,&(iq->t));
	   iq->start = start;
	   qinsert(homequeue,(struct queue *)iq);
/*	   opendoc(rootframe, NULL, &t, start, 1, OMREAD_ONLY, OMCONF_COPY);*/
	   [sender opendoc :&t :start];
	   numberofwindows++;

        }else{
          fprintf(stderr, "Don't know about %s = %s\n", name, line);
        }
      }
    }
   fclose(rcfd);
  }
    if(numberofwindows == 0){
        i = scantum("0.1.1.0.1.0.1", &t);  /* Hooray for hard coding */
	   assert(i);
/*	   opendoc(rootframe, NULL, &t, -1, -1, OMREAD_ONLY, OMCONF_COPY);*/
		   [sender opendoc :&t :-1];
    }
  if(!qvalid(homequeue)){
    fprintf(stderr,"what the hell \n");
  }
}
static renamed = FALSE;

void addtostartqueue(t)
  tumbler * t;
{
 struct iqte* iq;

	 iq=(struct iqte *)alloc(sizeof(struct iqte));
                           tumblercopy(t,&(iq->t));
                              /* start at current top line and character*/
                              iq->start = 0;//zzz
                              qinsert(startqueue,iq);
}
void savehomestorcfile()
{
	if(!renamed){
		localrename();
	}
        torcfile(homequeue,HOMEDOCUMENTTUMBLER);
}

void savepositionstorcfile()
{
	if(!renamed){
		localrename();
	}
  torcfile(startqueue,STARTDOCUMENTTUMBLER);
}
static void localrename()/* rename the rc file could us process id or something*/
	     /* right now uses .bak  maybe time and date stamp is good?*/
{
	renamed = TRUE;
	rename(RCFILENAME,RCBAKFILENAME);
}
static void torcfile(  struct queue *q,  char * type)
{
  struct iqte *temp;
    FILE *rcfd;
    char s[256];
  if ((rcfd = fopen(RCFILENAME, "a")) != NULL) {

	for(;;){
		temp =(struct iqte *)qremove(q);
		if(!temp){
			break;
		}
		editum(&(temp->t),s);
		fprintf(rcfd,"%s = %s ~ %d ~\n",type,s,temp->start);
		free((char *)temp);

	} ;
   }
   fclose(rcfd);
   free((char *)q);
}

/*  Data structure interconversion routines  */

/*  SCANTUM  --  Scans tumbler (terminated by a delimiter of
                     some form) and stores it into an internal
		                      tumbler buffer.  Returns TRUE if the tumbler
				                       was valid and FALSE if an error was detected.  */

bool scantum(char *s, tumbler *t)
     //char *s;
     //struct itumbler *t;
{
            int i, n;
	            unsigned long tval;
	            unsigned char delim;
	    #ifdef STDB
	    printf("scantum(%s)\n", s);
	    #endif

	            /* Scan exponent */

	            n = sscanf(s, "%ld%c", &tval, &delim);
	            assert(n == 2);
	            assert(tval >= 0);
	            assert(delim == XTDELIM || delim == XNEWLINE || delim == XDELIM);

	            t->exp = tval;

	            /* Scan tumbler digits */

	            i = 0;
	            while (delim == XTDELIM) {
			           s = (char *)strchr(s, delim) + 1;
				              assert(s != NULL);
				              delim = EOS;
				              n = sscanf(s, "%ld%c", &tval, &delim);
				   #ifdef STDB
				   printf("scanf(%s): n = %d, tval = %d, delim = %d\n", s, n, tval, delim);
				   #endif
				              assert((n == 2) || (n == 1 && delim == EOS));
				              assert(tval >= 0);

				              t->mantissa[i++] = tval;
			       }
	            assert(delim == XNEWLINE || delim == XDELIM || delim == EOS);

	            /* Zero fill right end of tumbler */

	            while (i < NPLACES)
		                 t->mantissa[i++] = 0;

	            return TRUE;
	}

/*  EDITUM  --  Edit internal tumbler to string.  Note that the resulting
                    string is terminated by an EOS, not the link delimiter. */

void editum(tumbler* t, char *s)
     //struct itumbler *t;
     //char *s;
{
    int i, j;
    char edbuf[20];

         sprintf(s, "%ld", t->exp);

         for (i = NPLACES - 1; i > 0; i--)
                 if (t->mantissa[i] != 0)
	             break;

         for (j = 0; j <= i; j++) {
            sprintf(edbuf, "%c%ld", XTDELIM, t->mantissa[j]);
            strcat(s, edbuf);
         }
}

