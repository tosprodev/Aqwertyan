//
//  InputHandler.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 9/19/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "InputHandler.h"
#import "Synchronizer.h"
#import "AudioPlayer.h"
#include <sys/time.h>
#import "mid2jmid.h"
#import "Conversions.h"
//#import "NotationDisplay.h"

@implementation InputHandler {
    BOOL ignore_keyboard;
    Piece *p;
    int keyboard_on[256];
    BOOL space_bar_pedal;
    int m_SM;
    AudioPlayer *audioPlayer;
    double lastYah;
}

+ (InputHandler *) sharedHandler {
    static InputHandler *theHandler = nil;
    
    if (theHandler == nil)
        theHandler = [InputHandler new];
    
    return theHandler;
}

+ (InputHandler *) bandHandler {
    static InputHandler *theHandler = nil;
    
    if (theHandler == nil) {
        theHandler = [InputHandler new];
        theHandler.Band = YES;
    }
    
    return theHandler;
}

+ (Piece *)readMusFile:(char *)file {
    return read_mus_file(file);
}

+ (void) deletePiece:(Piece *)p {
    delete_piece(p);
}

+ (NSArray *)getTracks:(NSString *)aFile {
    return get_program_events(aFile);
}

+ (NSArray *)getEvents:(NSString *)aFile {
    return get_events(aFile);
}

- (id)init {
    self = [super init];
    self.FreePlay = NO;
   // EchoOut = NULL;
	self.Thru = TRUE;
	self.Recording = FALSE;
	m_PS = NULL;
	//synchronizer = nil;
	//pDoc = NULL;
    //synchronizer = [Synchronizer new];
    scroll_penult = 1;
    return self;
}

//
//
//- (void)keyDown:(char)key velocity:(int)velocity {
//   // FILE *f;
//	int octave;
//	char *notename;
//	char buf[2];
//	unsigned char c;
//	Play_state *ps;
//	//int vol;
//    
//    if (self.IgnoreInput) return;
//	ps = m_PS;
//	c = key;
////	if (trace_keyboard) {
////        fprintf(ps->tf, "Down %c (%d) (ST:%d)\n", c, c, bowen_state);
////	}
//    
//    if (self.FreePlay) {
//        [[AudioPlayer sharedPlayer] playNote:44+(key - 'a') onChannel:0 withVelocity:velocity];
//        return;
//    }
//	if (!ignore_keyboard || (p != NULL && p->autoplay)) {
//		if (c == '\t') {
//			ps->tempo_factor *= 1.1;
//			return;
//		} else if (c == 220) {
//			ps->tempo_factor /= 1.1;
//			return;
//		}
//	}
//    
//	if (ignore_keyboard) return;
//	
//	if (keyboard_on[key]) return;
//	keyboard_on[key] = 1;
//    
//	buf[0] = key;
//	buf[1] = '\0';
//    
//	MidiEvent Evt;
//	Evt.time = 0xFFFFFFFF;
//    
//	if (buf[0] == ' ' && space_bar_pedal) {
//		Evt.status = 0xb0;
//		Evt.data1 = 64;
//		Evt.data2 = 127;
//		/* fprintf(ps->tf, "Space bar down\n"); */
//	} else {
//		notename = qwert_to_note(buf, &octave);
//		if (notename == NULL) {
//			//f = fopen("TRACE-FILE.txt", "a");
//			//if (f == NULL) { exit(0); }
//			//fprintf(f, "Unknown character code %d - %c\n", nChar, nChar);
//			//fclose(f);
//			return;
//		};
//		Evt.status = 0x90;
//		Evt.data1 = mid_key(notename, octave);
//		Evt.data2 = velocity;
//	}
//	[self ProcessMidiData:&Evt];
//}
//
//- (void)keyUp:(char)key {
//    int octave;
//	char *notename;
//	char buf[2];
//	Play_state *ps;
//    
//    if (self.IgnoreInput) return;
//    
//	ps = m_PS;
//    
//    if (self.FreePlay) {
//        
//        [[AudioPlayer sharedPlayer] unplayNote:44+(key - 'a') onChannel:0];
//        return;
//    }
//
//    
////	if (trace_keyboard) {
////        fprintf(ps->tf, "UP   %c (st:%d)\n", nChar, bowen_state);
////	}
//	if (!ignore_keyboard || (p != NULL && p->autoplay)) {
//		if (key == '\t' || key == 220) return;
//	}
//    
//	if (ignore_keyboard) return;
////	if (Bowen_Kybd) {
////		if (!is_reg_char(nChar)) return;
////		switch (bowen_state) {
////			case 0: return; break;
////			case 1: return; break;
////			case 2:
////				bowen_state = 3;
////				return;
////				break;
////			case 3: break;  /* The key up that we care about */
////			case 4:
////				bowen_state = 5;
////				return;
////				break;
////			case 5: return; break;
////			case 6:
////				bowen_state = 3;
////				return;
////				break;
////			default:
////				return;
////				break;
////		}
////	}
//	if (key == '\n' || !keyboard_on[key]) return;
//	keyboard_on[key] = 0;
//    
//	buf[0] = key;
//	buf[1] = '\0';
//    
//	MidiEvent Evt;
//	Evt.time = 0xFFFFFFFF;
//    
//	if (buf[0] == ' ' && space_bar_pedal) {
//		Evt.status = 0xb0;
//		Evt.data1 = 64;
//		Evt.data2 = 0;
//	} else {
//		notename = qwert_to_note(buf, &octave);
//		if (notename == NULL) return;
//		Evt.status = 0x80;
//		Evt.data1 = mid_key(notename, octave);
//		Evt.data2 = 60;
//	}
//	[self ProcessMidiData:&Evt];
//}
//
//- (BOOL) ProcessMidiData:(LPMIDIEVENT)lpEvent
//{
//	//MidiEvent EchoEvent;
//	//CMaxSeqView *view;
//	//CDialogErrbox ebox;
//	double cclock, mid1, mid2;
//	double d;
//	int tempo;
//    struct timeval tv;
//    
//    
//	if (self.Recording) {
//		if (StopNote > 0 && (lpEvent->status & 0XF0) == 0x90 && lpEvent->data1 == StopNote) {
//			[self FinishRecording];
//		} else if (StopWheel && (lpEvent->status & 0xF0) == 0xE0) {
//			[self FinishRecording];
//		} else if (StopProgram && (lpEvent->status & 0XF0) == 0xC0) {
//			[self FinishRecording];
//		} else if (StopPedal && (lpEvent->status & 0xF0) == 0xB0 && lpEvent->data1 == 64) {
//			[self FinishRecording];
//		}
//	}
//	if (m_PS != NULL) {
//		//cclock = clock();
//        gettimeofday(&tv, NULL);
//        cclock = tv_to_t(&tv)*CLOCKS_PER_SEC;
//		m_PS->current_time = (cclock - m_PS->base_clock_time)/(double)CLOCKS_PER_SEC;
//        
//		if (lpEvent->time == 0xFFFFFFFF) {
//			d = (m_PS->last_clock - m_PS->base_clock_time);
//			tempo = [[Synchronizer sharedSynchronizer] tempo];
//			d = (d * .480)*(1000000.0/(double)tempo) + .5;
//			mid1 =  d;
//			d = (cclock - m_PS->base_clock_time);
//			d = (d * .480)*(1000000.0/(double)tempo) + .5;
//			mid2 =  d;
//			lpEvent->time = (mid2-mid1);
////            NSLog(@"lpevent time: %lu", lpEvent->time);
////            if (lpEvent->time < 1) {
////                NSString *s = @"";
////            }
//		}
//        m_PS->one_back = m_PS->last_clock;
//		m_PS->last_clock = cclock;
//		if (StopNote > 0 && (lpEvent->status & 0XF0) == 0x90 && lpEvent->data1 == StopNote) {
//			[self FinishPiece];
//		} else if (StopWheel && (lpEvent->status & 0xF0) == 0xE0) {
//			[self FinishPiece];
//		} else if (StopF0 && (lpEvent->status == 0xF0)) {
//			[self FinishPiece];
//		} else {
//           // NSLog(@"play measure");
//			[self PlayMeasure:lpEvent];
//            
//		}
//        
//		return FALSE;
//    }
////	} else if(EchoOut && ThruEnabled && IsRecording()) {
////		// echo it now by setting time to -1
////		EchoEvent = *lpEvent;
////		EchoEvent.time = (DWORD)-1;
////		EchoOut->Put(&EchoEvent);
////	} else if (pDoc != NULL &&
////               (Sync == NULL || (Sync != NULL && !Sync->IsCmping() &&
////                                 !Sync->IsRecording() && !Sync->IsPlaying()))) {
////		view = (CMaxSeqView *) pDoc->GetView();
////		if (view->Scts.m_bOn) {
////			if ((lpEvent->status & 0xF0) == 0x80 ||
////				((lpEvent->status & 0xF0) == 0x90 && lpEvent->data2 == 0)) {
////				if (lpEvent->data1 == view->Scts.RecTB) {
////					view->OnRecordStart();
////					return FALSE;
////				} else if (lpEvent->data1 == view->Scts.PlayMus) {
////					view->OnStartCmp();
////				} else if (lpEvent->data1 == view->Scts.PlayTB) {
////					view->OnPlayStart();
////				}
////			} else if ((lpEvent->status & 0xF0) == 0x90 && lpEvent->data2 > 0) {
////				if (lpEvent->data1 == view->Scts.Add && view->p != NULL) {
////					view->OnAdd();
////				} else if (lpEvent->data1 == view->Scts.AddM1 && view->p != NULL) {
////					view->OnAddm1();
////				} else if (lpEvent->data1 == view->Scts.SmInc && view->p != NULL) {
////					view->OnSmBump(1);
////				} else if (lpEvent->data1 == view->Scts.SmDec && view->p != NULL) {
////					view->OnSmBump(-1);
////				} else if (lpEvent->data1 == view->Scts.NextMark && view->p != NULL) {
////					view->OnMarkBump(1);
////				} else if (lpEvent->data1 == view->Scts.PrevMark && view->p != NULL) {
////					view->OnMarkBump(-1);
////				} else if (lpEvent->data1 == view->Scts.NextMetro && view->p != NULL) {
////					view->OnMetroBump(1);
////				} else if (lpEvent->data1 == view->Scts.PrevMetro && view->p != NULL) {
////					view->OnMetroBump(-1);
////				} else if (lpEvent->data1 == view->Scts.NextDenom && view->p != NULL) {
////					view->OnDenomBump(1);
////				} else if (lpEvent->data1 == view->Scts.PrevDenom && view->p != NULL) {
////					view->OnDenomBump(-1);
////				} else if (lpEvent->data1 == view->Scts.NextMeasure && view->p != NULL) {
////					view->OnMeasureBump(1);
////				} else if (lpEvent->data1 == view->Scts.PrevMeasure && view->p != NULL) {
////					view->OnMeasureBump(-1);
////				} else if (lpEvent->data1 == view->Scts.FirstMeasure && view->p != NULL) {
////					view->ResetToFirstMeasure();
////				} else if (lpEvent->data1 == view->Scts.ShortcutsOff && view->p != NULL) {
////					view->Scts.m_bOn = FALSE;
////				}
////			}
////		}
////	}
//
//    
//	// return TRUE to append this event to any attached tracks
//	return TRUE;
//}
////
////
////
////
////- (void) RedrawDisplay
////{
//////	CMaxSeqView *view;
//////	view = (CMaxSeqView *) pDoc->GetView();
//////    
//////	view->AddDisplayNote(NULL);
//////	view->Invalidate();
////}
////
//- (void) DeleteYAH:(int) invalidate
//{
//	//CMaxSeqView *view;
//	Play_state *ps;
//	CGRect r;
//	int x, y;
//	int fnd;
//	Rb_node rtmp, rtmp2;
//	Measure *m;
//	Line *l;
//	Note *n;
//	Dlist dtmp;
//    
//	//view = (CMaxSeqView *) pDoc->GetView();
//
//}
////
//- (void) DisplayYAH:(int) invalidate
//{
//	//CMaxSeqView *view;
//	Play_state *ps;
//	Rb_node tmp;
//	Measure *m;
//	int done;
//	double x;
//	CGRect r;
//    
//	ps = m_PS;
//	if (ps->YAH < 0) return;
//    
//	if (ps->YAH_displayed != -1) {
//		//fprintf(ps->tf, "ERROR -- YAH_displayed != -1\n");
//		//exit(1);
//	}
//    
//	done = 0;
//    
//	for (tmp = ps->firstm; tmp != ps->lastm && !done; tmp = rb_next(tmp)) {
//		m = (Measure *) rb_val(tmp);
//		if (m->beatid <= ps->YAH && m->beatid+m->meter_num > ps->YAH) done = 1;
//	}
//    
//	if (!done) return;
//	
//	//view = (CMaxSeqView *) pDoc->GetView();
//	ps->YAH_dmeasure = m;
//    
//	ps->YAH_Draw_bottom = 0;
//	ps->YAH_Draw_top = 0;
//    
//	/* That first boolean expression may always be false -- I'm just
//     being safe */
//	//if ((self.NotationDisplay.XM_view_only && m_PS->p->qwertyheight > 0) && self.NotationDisplay.QBar_Height == 0) return;
//    
//	if (!self.NotationDisplay.NOW_MAM && !self.NotationDisplay.NOW_XM) return;
//	if (!self.NotationDisplay.NOW_XM && self.NotationDisplay.XM_view_only) return;
//	if (!self.NotationDisplay.NOW_MAM && self.NotationDisplay.QBar_Height == 0) return;
//    
//	//x = m->left + ((ps->YAH - m->beatid) / ((double) m->meter_num)) * (m->right-m->left);
//    CGRect rect =  [self.NotationDisplay rectForMeasure:m];
//    x = rect.origin.x + ((ps->YAH - m->beatid) / ((double) m->meter_num)) / rect.size.width;
//   // NSLog(@"%f --x",x);
//    
//    
//	r = [self.NotationDisplay SpacerRect:x right:x];//->SpacerRect(x, x);
//    
//	
//	if (self.NotationDisplay.NOW_XM && self.NotationDisplay.QBar_Height > 0) {
//        r.origin.y = [self.NotationDisplay QBar_Top:x lr:'l'];
//    }
//    if (self.NotationDisplay.NOW_MAM && ((!self.NotationDisplay.XM_view_only) || ps->p->qwertyheight == 0)) {
//        r.size.height = [self.NotationDisplay MAM_Y:ps->minkey x:x lr:'l' playstate:m_PS] - r.origin.y;
//    }// r.bottom = view->MAM_Y(ps->minkey-2, x, 'l');
//	ps->YAH_Draw_bottom = r.origin.y + r.size.height;
//	ps->YAH_Draw_top = r.origin.y;
//
////	r = view->InvRect(r);
////	ps->YAH_Inv_bottom = r.bottom;
////	ps->YAH_Inv_top = r.top;
////	r.right += view->YAH_width;
//    
//	ps->YAH_displayed = r.origin.x;
//  //  NSLog(@"displayed - %f", r.origin.x);
//    [self.NotationDisplay DrawYAH:1];
//    
//	if (invalidate) {
//		//view->InvalidateRect(r, FALSE);
//	}
//}
////
//- (void) DisplayNote:(Note *)n
//{
//    
//	//CMaxSeqView *view;
//	CGRect rect;
//	double x1, x2;
//	double qby;
//	Note *n2;
//	int more, i;
//    
//	/* fprintf(m_PS->tf, "DisplayNote %s/%d %d\n", n->name, n->octave, n->m->number);
//     fflush(m_PS->tf); */
//    
//	/* Find any note to which this note is tied, and see if it is in the display */
//	while (n->left == -1 && n->backcarry != NULL) n = n->backcarry;
//	while (n->left == -1 && n->carry != NULL) n = n->carry;
//	if (n->left == -1) return;
//    
//	/* Ok -- so, n is now a note to which the given note is tied or carried
//     that is in the display, and thus needs to be displayed */
//    
//	//view = (CMaxSeqView *) pDoc->GetView();
//    
//	/* Find the left extent and the right extent of the note */
//    
//	n2 = n;
//	while (n2->backcarry != NULL && n2->backcarry->left != -1) n2 = n2->backcarry;
//	x1 = (double) n2->left;
//	while (n2->carry != NULL && n2->carry->left != -1) n2 = n2->carry;
//	x2 = (double) n2->right;
//    
//	/* Display the note */
//    
//	more = 1;
//	if ((!self.NotationDisplay.XM_view_only) || m_PS->p->qwertyheight == 0) {
////		for (i = 0; more; i++) {
//////			rect = view->InvRect(view->MAMRect(x1, n->bottom, x2, n->top, i, &more));
//////			view->InvalidateRect(rect, TRUE);
////		}
//		[self.NotationDisplay AddDisplayNote:n];
//        //[self.NotationDisplay DrawMeasures];
//	}
//    
//	while (n->backcarry != NULL) n = n->backcarry;
//	if (n->exmatch != NULL && n->exmatch->qwert && (!self.NotationDisplay.XM_fingerview || n->exmatch->fingerheight >= 0)) {
//		/* You have to add lyric_height because lyrics are part of the qwertybar */
//		qby = self.NotationDisplay.Lyric_Height;
//		if (self.NotationDisplay.XM_fingerview) {
//			qby += n->exmatch->fingerheight;
//			if (m_PS->p->heights[LH] == 0) qby -= 5;
//		} else if (n->linetype == RH) {
//			qby += (n->exmatch->height+self.NotationDisplay.p->heights[0]);
//		} else {
//			qby += n->exmatch->height;
//		}
//		more = 1;
////		for (i = 0; more; i++) {
//////			rect = view->QBarRect(x1, x2, qby, i, &more);
//////			rect = view->InvRect(rect);
//////			view->InvalidateRect(rect, TRUE);
////		}
//        if (!((!self.NotationDisplay.XM_view_only) || m_PS->p->qwertyheight == 0)) {
//            [self.NotationDisplay AddDisplayNote:n];
//        }
//	}
//   
//	double newyah;
//    
//	newyah = [self.NotationDisplay CalcYAH:m_PS];
//	if (newyah != m_PS->YAH) {
//        [self DeleteYAH:1];
//		//DeleteYAH(1);
//		m_PS->YAH = newyah;
//		[self DisplayYAH:1];
//		[self ShouldIScroll];
//	}
//}
//
//- (Play_state *)PS {
//    return m_PS;
//}
////
//- (void) FinishPiece
//{
//	Dlist tmp;
//	MidiEvent *mep;
//	int nevents;
//	int i;
//    
//	FILE *f;
//         [[Synchronizer sharedSynchronizer] stop];
//    [[AudioPlayer sharedPlayer] resetProgram];
////    view = (CMaxSeqView *) pDoc->GetView();
////    view->ignore_keyboard = 1;
////	view->p->autoplay = 0;
////    
////	Sync->IsCmping(FALSE);
////	Sync->Stop();
//	// If there are any events (i.e. the piece was played),
//	// kill any recorded midi tracks.  This will set us up with one empty track.
//	// Then put all events onto this track.
////	if (m_PS->total_nevents > 0 && pDoc->OnNewDocument()) {
////		pDoc->pTrackList[0]->IsRecording(TRUE);
////		dl_traverse(tmp, m_PS->midi_events) {
////			mep = (MidiEvent *) tmp->val;
////			nevents = (tmp->flink == m_PS->midi_events) ? m_PS->nevents : EVBUF;
////			for (i = 0; i < nevents; i++) pDoc->pTrackList[0]->Write(&mep[i]);
////		}
////		//pDoc->pTrackList[0]->IsRecording(FALSE);
////	}
////	if (view->record_to != NULL) {
////		//pDoc->OnSaveDocument(view->record_to);
////	}
////    
////	if (view->stats_to != NULL) {
////		f = fopen(view->stats_to, "w");
////		if (f != NULL) {
////			for (i = 0; i < 2; i++) {
////				fprintf(f, "IGNORE-EXMATCH    %d %5d\n", i, m_PS->stats[i].ignored_exmatch);
////				fprintf(f, "IGNORE-OTHERHAND  %d %5d\n", i, m_PS->stats[i].ignored_otherhand);
////				fprintf(f, "IGNORE-STRAYCHORD %d %5d\n", i, m_PS->stats[i].ignored_straychord);
////				fprintf(f, "SKIPPED           %d %5d\n", i, m_PS->stats[i].skipped);
////				fprintf(f, "PLAYED            %d %5d\n", i, m_PS->stats[i].played);
////			}
////			fclose(f);
////		}
////	}
////	if (view->p->killonstop) exit(0);
//   
//	[self DeletePlayState];
////	Sync->UpdateViews();
////	Sync = NULL;
//}
////
////
//#define DOWRITE 1
//#define MAXVOL 127
//
//static Note NOTE_IGNORE;
//static Note *Note_Ignore = &NOTE_IGNORE;
//
//int mins[3] = { 0, 60, 128 };
//int maxs[3] = { 59, 127, 128 };
//
//#define LR(note) ((note) >= mins[1])
//#define LEFT 0
//#define RIGHT 1
//
//#define IGNORE_NOTE -1
//#define REDO_EVENT -2
//#define TRILL_NOTE -3
////
//int LRLINE(Line *l)
//{
//    if (strncmp(l->name, "LH", 2) == 0) return 0;
//    if (strncmp(l->name, "RH", 2) == 0) return 1;
//    return -1;
//}
////
//void musplay_error(char *s)
//{
////	CDialogErrbox ebox;
////    
////	ebox.m_strErrstring = s;
////	int i = ebox.DoModal();
//    NSLog(@"musplay_error: %s", s);
//	exit(1);
//}
////
//- (void) DeletePlayState
//{
//	Play_state *ps;
//	Dlist tmp;
//	int i;
//    
//	ps = m_PS;
//	if (ps == NULL) return;
//	//fclose(m_PS->tf);
//	rb_free_tree(ps->YAH_to_delete);
//	rb_free_tree(ps->YAH_mtr);
//	rb_free_tree(ps->YAH_ntr);
//	dl_delete_list(ps->autoplaying);
//	free(ps->ison);
//	free(ps->lptrs);
//	free(ps->notes);
//	free(ps->cbeat);
//	free(ps->lln);
//	free(ps->buf);
//	free(ps->lines);
//	free(ps->nlookaheadtmp);
//	for (i = 0; i < 2; i++) {
//		rb_free_tree(ps->project[i]);
//	}
//	free_krec(ps->k);
//	dl_traverse(tmp, ps->midi_events) {
//		free(tmp->val);
//	}
//	dl_delete_list(ps->midi_events);
//	free(ps);
//	m_PS = NULL;
//}
////
//- (void) InitPlayState:(Piece *)p
//{
//    Play_state *ps;
//    int i;
//    Rb_node tmp, tmp2;
//    Dlist tmp3;
//    Measure *m;
//    Line *l;
//    Note *n;
//    
//    
//   // view = (CMaxSeqView *) pDoc->GetView();
//    
//    if (m_PS != NULL) {
//       // return;
//        //musplay_error("InputHandler::InitPlayState -- m_PS is not NULL");
//    }
//    
//    ps = (Play_state *) malloc(sizeof(Play_state));
////    ps->tf = fopen("trace.txt", "w");
////    if (ps->tf == NULL) {
////        musplay_error("Could not open trace file -- it's probably open in an MS word window");
////        return;
////    }
////    fprintf(ps->tf, "%s\n", p->name);
//    ps->p = p;
//    ps->inst_default = 0;
//    ps->tempo_factor = 1;
//    ps->autoplaying = make_dl();
//    ps->windowbeats = NULL;
//    ps->leftmeasures = NULL;
//    ps->rightmeasures = NULL;
//    ps->voffset = 0;
//    ps->last_played = NULL;
//    ps->YAH_displayed = -1;
//    ps->YAH_to_delete = make_rb();
//    ps->YAH_ntr = make_rb();
//    ps->YAH_mtr = make_rb();
//    ps->YAH_Draw_bottom = ps->YAH_Draw_top = -1;
//    ps->YAH_Inv_bottom = ps->YAH_Inv_top = -1;
//    ps->volperc = 100;
//    ps->firstm = NULL;
//    ps->lastm = NULL;
//    ps->skip_until = -1.0;
//    
//    
//    // Set maxkey and minkey so that the minimum window size is 20
//    
//    ps->maxkey = p->maxkey;
//    ps->minkey = p->minkey;
//    if (ps->maxkey < 0) { ps->maxkey = 60; ps->minkey = 60; }
//    if (ps->maxkey - ps->minkey < 20) {
//        ps->maxkey += (20 - (ps->maxkey-ps->minkey))/2;
//        ps->minkey -= (20 - (ps->maxkey-ps->minkey));
//    }
//    ps->ison  = (int *) malloc(sizeof(int)*p->tlines);
//    ps->lptrs = (Dlist *) malloc(sizeof(Dlist)*p->tlines);
//    ps->notes = (Note **) malloc(sizeof(Note *)*p->tlines);
//    ps->cbeat = (int *) malloc(sizeof(int)*p->tlines);
//    ps->lln = (Keys *) malloc(sizeof(Keys)*p->tlines);
//    ps->buf = (unsigned char *) malloc(sizeof(unsigned char) * (p->tlines*100));
//    ps->nlookaheadtmp = (int *) malloc(sizeof(int)*p->tlines);
//    ps->bufptr = 0;
//    for (i = 0; i < 128; i++) ps->bufnotes[i] = NULL;
//    ps->trill_note = NULL;
//    ps->trill_line = -1;
//    for (i = 0; i < 16; i++) ps->program[i] = -1;
//    
//    ps->lines = (Line **) malloc(sizeof(Line *)*p->tlines);
//    
//    for (i = 0; i < p->tlines; i++) {
//        ps->ison[i] = 0;
//        ps->lptrs[i] = NULL;
//        ps->notes[i] = NULL;
//        ps->cbeat[i] = -1;
//        ps->lines[i] = NULL;
//        ps->lln[i].isvalid = 0;
//        ps->lln[i].key = -1;
//        ps->lln[i].endbeat = -1;
//    }
//    
//    ps->m = NULL;
//    ps->endbeat = -1;
//    ps->mask = 0;
//    
//    for (i = 0; i < 2; i++) {
//        ps->curbeat[i] = -1;
//        ps->beatid[i] = -1;
//        ps->lhp[i] = -1;
//        ps->lhpt[i] = -1;
//        ps->n_ntp[i] = 0;
//        ps->ngrace[i] = 0;
//        ps->nnotes[i] = 0;
//        ps->project[i]  = make_rb();
//        ps->cbtime[i] = -1;
//        ps->cbid[i] = -1;
//        ps->lbtime[i] = -1;
//        ps->lbid[i] = -1;
//        ps->mbtime[i] = -1;
//        ps->mbid[i] = -1;
//        ps->tempo[i] = -1;
//        ps->stats[i].ignored_otherhand = 0;
//        ps->stats[i].ignored_straychord = 0;
//        ps->stats[i].ignored_exmatch = 0;
//        ps->stats[i].skipped = 0;
//        ps->stats[i].played = 0;
//    }
//    
//    for (i = 0; i < 128; i++) ps->playing[i] = 0;
//    for (i = 0; i < 128; i++) ps->last_off[i] = -1;
//    for (i = 0; i < 128; i++) ps->mapped[i] = NULL;
//    ps->nplaying = 0;
//    
//    ps->k = new_krec();
//    ps->cur_midi_time = -1;
//    ps->midi_events = make_dl();
//    ps->nevents = EVBUF;
//    ps->total_nevents = 0;
//    m_PS = ps;
//    
//    /* Now, reset all the notes in the piece */
//    
//    rb_traverse(tmp, p->measures) {
//        m = (Measure *) tmp->v.val;
//        rb_traverse(tmp2, m->lines) {
//            l = (Line *) tmp2->v.val;
//            dl_traverse(tmp3, l->l) {
//                n = (Note *) tmp3->val;
//                n->playing = 0;
//                n->left = n->right = n->top = n->bottom = -1;
//                if (n->trill) {
//                    n->trillnote->playing = 0;
//                    n->trillnote->left = n->trillnote->right = n->trillnote->top = n->trillnote->bottom = -1;
//                }
//            }
//        }
//    }
//}
////
/////* Advance_line goes to the next note in the line */
////
//- (void) AdvanceLine:(int)ln        /* Line number (l->number) */
//{
//    m_PS->cbeat[ln] += m_PS->notes[ln]->dur_num * m_PS->m->lcm
//    / m_PS->notes[ln]->dur_den;
//    m_PS->lptrs[ln] = m_PS->lptrs[ln]->flink;
//    if (m_PS->lptrs[ln] == m_PS->lines[ln]->l) {
//        m_PS->notes[ln] = NULL;
//        if (m_PS->cbeat[ln] != m_PS->endbeat) {
//            fprintf(m_PS->tf, "Internal error: AL: %d %s %d %d\n", m_PS->m->number,
//                    m_PS->lines[ln]->name, m_PS->cbeat[ln], m_PS->endbeat);
//            musplay_error("Internal error -- check the trace file");
//        }
//    } else {
//        m_PS->notes[ln] = (Note *) m_PS->lptrs[ln]->val;
//        
//        /* If we get a bug, it might be here.  More things may have to be
//         set to -1 than tempo and mbid */
//        
//        if (!m_PS->m->use_tempo || m_PS->notes[ln]->tempo_reset) {
//            if (ln < m_PS->p->start[1]) {
//                m_PS->tempo[0&m_PS->mask] = -1;
//                m_PS->mbid[0&m_PS->mask] = -1;
//            } else if (ln < m_PS->p->start[2]) {
//                m_PS->tempo[1&m_PS->mask] = -1;
//                m_PS->mbid[1&m_PS->mask] = -1;
//            } else {
//                char s[1000];
//                sprintf(s, "INTERNAL ERROR: M: %d L: %s tempo_reset in tie line",
//                        m_PS->m->number, m_PS->lines[ln]->name);
//                musplay_error(s);
//            }
//        }
//    }
//}
////
/////* GoToNextPlayable calls AdvanceLine until either the line is
//// done or the note in the line is playable (i.e. not a carry or a rest) */
////
//- (void) GoToNextPlayable:(int)ln         /* Line number (l->number) */
//{
//    while(m_PS->ison[ln] && m_PS->notes[ln] != NULL && m_PS->notes[ln]->key <= 0) {
//        if (m_PS->notes[ln]->key < 0) {  /* deal with carries */
//            if(m_PS->lln[ln].isvalid && m_PS->lln[ln].endbeat >= 0) {
//                m_PS->lln[ln].endbeat = m_PS->notes[ln]->beat_off;
//            }
//        }
//        [self AdvanceLine:ln];
//    }
//}
////
////void print_play_state(Play_state *ps)
////{
////    int hand;
////    Rb_node rt;
////    int ln;
////    int *ptr;
////    
////    fprintf(ps->tf, "Play State: \n");
////    fprintf(ps->tf, "  Measure: %d, beats: %d/%d\n", ps->m->number,
////            ps->m->lcm, ps->endbeat);
////    for(hand = 0; hand < 2; hand++) {
////        fprintf(ps->tf, "  Hand %d: beat %d\n", hand, ps->curbeat[hand]);
////        fprintf(ps->tf, "    Notes to play: %d\n", ps->n_ntp[hand]);
////        for (ln = ps->p->start[hand]; ln < ps->p->start[hand+1]; ln++) {
////            fprintf(ps->tf, "    Line #%d %d", ln, ps->ison[ln]);
////            if (ps->ison[ln]) {
////                fprintf(ps->tf, " %s", ps->lines[ln]->name);
////                if (ps->cbeat[ln] == ps->curbeat[hand] && ps->notes[ln] != NULL) {
////                    fprintf(ps->tf, " note: %d %d/%d", ps->notes[ln]->key,
////                            ps->notes[ln]->dur_num, ps->notes[ln]->dur_den);
////                }
////            }
////            fprintf(ps->tf, "\n");
////        }
////        fprintf(ps->tf, "    Projection tree:\n");
////        rb_traverse(rt, ps->project[hand]) {
////            ln = rt->k.ikey;
////            ptr = (int *) rt->v.val;
////            fprintf(ps->tf, "      Line #%d %s Projection %d lln.key %d lln.endbeat %d\n", ln,
////                    ps->lines[ln]->name, *ptr, ps->lln[ln].key,
////                    ps->lln[ln].endbeat);
////            
////        }
////    }
////}
////
//
///*
// static int set_tie(Measure *m, Line *l, Line *tln, Note *n, int onoff, Piece *p)
// {
// Note *tn;
// Dlist dtmp;
// char s[1000];
// 
// if (onoff == ON) {
// if (n->key <= 0) return 1;
// } else {
// if (n->carry != NULL) return 1;
// if (n->key == 0) return 1;
// }
// 
// dl_traverse(dtmp, tln->l) {
// tn = (Note *) dtmp->val;
// if (onoff == ON) {
// if (tn->beat_on == n->beat_on && tn->grace_num == n->grace_num) {
// if (tn->key <= 0) {
// sprintf(s, "Error M: %d L: %s: Beat %d: %s %s %s",
// m->number, l->name, n->beat_on,
// "can't tie on to", tln->name, ": rest/carry.");
// mus_error(p, NULL, s);
// return 0;
// }
// dl_insert_b(tn->on_ties, n);
// return 1;
// }
// } else if (onoff == OFF) {
// if (tn->beat_off == n->beat_off && tn->grace_num == n->grace_num) {
// if (tn->key == 0) {
// sprintf(s, "Error M: %d L: %s: Beat %d: %s %s %s",
// m->number, l->name, n->beat_on,
// "can't tie off to", tln->name, ": it's a rest.");
// mus_error(p, NULL, s);
// return 0;
// }
// if (tn->carry != NULL) {
// sprintf(s, "Error M: %d L: %s: Beat %d: %s %s %s",
// m->number, l->name, n->beat_on,
// "can't tie off to", tln->name,
// ": it's a carried note.");
// mus_error(p, NULL, s);
// return 0;
// }
// dl_insert_b(tn->off_ties, n);
// return 1;
// }
// }
// }
// sprintf(s, "Error M: %d L: %s: Beat %d: Can't tie to %s %d -- no matching note",
// m->number, l->name, n->beat_on, tln->name, onoff);
// mus_error(p, NULL, s);
// return 0;
// */
//
//+ (BOOL) carriesAreSame:(Note *)aNote otherNote:(Note *)anotherNote {
//    double off1, off2;
//    Note *n;
//    
////    n = aNote;
////    while (n != NULL) {
////        off1 = n->beatoffid;
////        n = n->carry;
////    }
////    
////    n = anotherNote;
////    while (n != NULL) {
////        off2 = n->beatoffid;
////        n = n->carry;
////    }
//    
//    return anotherNote->carrytc->beatoffid == aNote->carrytc->beatoffid;
//}
//
//+ (Note *)copyNote:(Note *)aNote {
//    Note *nn = copy_note(aNote);
//    
//    Note *theCarry = aNote->carry, *theOtherCarry = nn;
//    while (theCarry != NULL) {
//        theOtherCarry->carry = copy_note(theCarry);
//        if (theOtherCarry != nn) theOtherCarry->carry->backcarry = theOtherCarry;
//        theCarry = theCarry->carry;
//        theOtherCarry = theOtherCarry->carry;
//    }
//    
//    
//    theCarry = nn;
//    while (theCarry->carry != NULL) {
//        theCarry = theCarry->carry;
//    }
//    nn->carrytc = theCarry;
//    theCarry->backcarrytc = nn;
//   
//    return nn;
//    
//}
//
//+ (void) tieNote:(Note *)anotherNote toNote:(Note *)aNote {
//    Note *copy = [InputHandler copyNote:anotherNote];
//    copy->m = anotherNote->m;
//    copy->beatid = anotherNote->beatid;
//    copy->beatoffid = anotherNote->beatoffid;
//    
//    if (aNote->on_ties == NULL) aNote->on_ties = make_dl();
//    dl_insert_b(aNote->on_ties, copy);
//    
//    if (aNote->carrytc->off_ties == NULL) aNote->carrytc->off_ties = make_dl();
//    dl_insert_b(aNote->carrytc->off_ties, copy->carrytc);
//    
//    while (copy != NULL) {
//        copy->linetype = TL;
//        copy = copy->carry;
//    }
//    
//    while (anotherNote != NULL) {
//        anotherNote->octave = -100;
//        anotherNote->key = 0;
//        anotherNote = anotherNote->carry;
//    }
//}
//
//+ (void)doColumns:(Piece *)aPiece {
//    Rb_node theMeasureIterator, theLineIterator;
//    Dlist theNoteIterator;
//    
//    
//    rb_traverse(theMeasureIterator, aPiece->measures) {
//        Measure *theMeasure = (Measure *)theMeasureIterator->v.val;
//        rb_traverse(theLineIterator, theMeasure->lines) {
//            Line *theLine = (Line *)theLineIterator->v.val;
//            
//            dl_traverse(theNoteIterator, theLine->l) {
//                Note *theNote = (Note *)theNoteIterator->val;
//                
//                if (theNote->key < 1)
//                    continue;
//                
//                if (theNote->exmatch != NULL) {
//                    [Conversions getKeysForKey:theNote->exmatch->name[0] buffer:theNote->exmatch->colkeys];
//                    char theNewQwert = [[NSString stringWithFormat:@"%d",[Conversions columnForKey:theNote->exmatch->name[0]]] characterAtIndex:0];
//                    theNote->exmatch->name[0] = theNewQwert;
//                }
//            }
//        }
//    }
//    
//    aPiece->columns = 1;
//}
//
//+ (void) getKeysForKey:(char)key buffer:(int *)array {
//    int octave = 0;
//    
//    if (key >= 'A' && key <= 'Z') key += ('a' - 'A');
//    char theKey[2];
//    theKey[1] = '\0';
//    if (key == '1' || key == 'q' || key =='a' || key == 'z') {
//        theKey[0] = '1';
//        array[0] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = 'q';
//        array[1] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = 'a';
//        array[2] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = 'z';
//        array[3] = mid_key(qwert_to_note(theKey, &octave), octave);
//        return;
//    }
//    if (key == '2' || key == 'w' || key =='s' || key == 'x') {
//        theKey[0] = '2';
//        array[0] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = 'w';
//        array[1] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = 's';
//        array[2] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = 'x';
//        array[3] = mid_key(qwert_to_note(theKey, &octave), octave);
//        return;
//    }
//    if (key == '3' || key == 'e' || key =='d' || key == 'c') {
//        theKey[0] = '3';
//        array[0] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = 'e';
//        array[1] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = 'd';
//        array[2] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = 'c';
//        array[3] = mid_key(qwert_to_note(theKey, &octave), octave);
//        return;
//    }
//    if (key == '4' || key == 'r' || key =='f' || key == 'v') {
//        theKey[0] = '4';
//        array[0] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = 'r';
//        array[1] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = 'f';
//        array[2] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = 'v';
//        array[3] = mid_key(qwert_to_note(theKey, &octave), octave);
//        return;
//    }
//    if (key == '5' || key == 't' || key =='g' || key == 'b') {
//        theKey[0] = '5';
//        array[0] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = 't';
//        array[1] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = 'g';
//        array[2] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = 'b';
//        array[3] = mid_key(qwert_to_note(theKey, &octave), octave);
//        return;
//    }
//    if (key == '6' || key == 'y' || key =='h' || key == 'n') {
//        theKey[0] = '6';
//        array[0] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = 'y';
//        array[1] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = 'h';
//        array[2] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = 'n';
//        array[3] = mid_key(qwert_to_note(theKey, &octave), octave);
//        return;
//    }
//    if (key == '7' || key == 'u' || key =='j' || key == 'm') {
//        theKey[0] = '7';
//        array[0] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = 'u';
//        array[1] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = 'j';
//        array[2] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = 'm';
//        array[3] = mid_key(qwert_to_note(theKey, &octave), octave);
//        return;
//    }
//    if (key == '8' || key == 'i' || key =='k' || key == ',') {
//        theKey[0] = '8';
//        array[0] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = 'i';
//        array[1] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = 'k';
//        array[2] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = ',';
//        array[3] = mid_key(qwert_to_note(theKey, &octave), octave);
//        return;
//    }
//    if (key == '9' || key == 'o' || key =='l' || key == '.') {
//        theKey[0] = '9';
//        array[0] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = 'o';
//        array[1] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = 'l';
//        array[2] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = '.';
//        array[3] = mid_key(qwert_to_note(theKey, &octave), octave);
//        return;
//    }
//    if (key == '0' || key == 'p' || key ==';' || key == '/') {
//        theKey[0] = '0';
//        array[0] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = 'p';
//        array[1] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = ';';
//        array[2] = mid_key(qwert_to_note(theKey, &octave), octave);
//        theKey[0] = '/';
//        array[3] = mid_key(qwert_to_note(theKey, &octave), octave);
//        return;
//    }
//}
//
//+ (void) doChording:(Piece *)aPiece {
//    Rb_node theMeasureIterator, theLineIterator1, theLineIterator2;
//    Dlist theNoteIterator1, theNoteIterator2;
//    Dlist theNotesToRemove;
//    Note *theOtherNote;
//    Line *theOtherLine;
//    
//    rb_traverse(theMeasureIterator, aPiece->measures) {
//        Measure *theMeasure = (Measure *)theMeasureIterator->v.val;
//        rb_traverse(theLineIterator1, theMeasure->lines) {
//            Line *theLine = (Line *)theLineIterator1->v.val;
//            
//            dl_traverse(theNoteIterator1, theLine->l) {
//                Note *theNote = (Note *)theNoteIterator1->val;
//               
//                if (theNote->key < 1)
//                    continue;
//                
//                
//                
//                rb_traverse(theLineIterator2, theMeasure->lines) {
//                    theOtherLine = (Line *)theLineIterator2->v.val;
//                    
//                    theNotesToRemove = make_dl();
//                    dl_traverse(theNoteIterator2, theOtherLine->l) {
//                        theOtherNote = (Note *)theNoteIterator2->val;
//                        
//                        // Tie together all notes that start and stop at the same time
//                        if (theNote->carry != NULL && theOtherNote->carry != NULL) {
//                         //   NSLog(@"carry");
//                        }
//                        if ((theNote != theOtherNote) && (theOtherNote->key > 0) && (theOtherNote->beatid == theNote->beatid) && (theOtherNote->carrytc->beatoffid == theNote->carrytc->beatoffid)) {
//                            dl_insert_b(theNotesToRemove, theOtherNote);
//                        }
//                    }
//                    dl_traverse(theNoteIterator2, theNotesToRemove) {
//                        theOtherNote = (Note *)theNoteIterator2->val;
//                        [InputHandler tieNote:theOtherNote toNote:theNote];
//                        
//                    }
//                    dl_delete_list(theNotesToRemove);
////                    if (dl_count(theOtherLine->l) == 0) {
////                        rb_delete_val(theMeasure->lines, theOtherLine);
////                    }
//                }
//            }
//            
//        }
//    }
//}
//
//+ (void)normalize:(Piece *)aPiece {
//    Rb_node theMeasureIterator, theLineIterator;
//    Dlist theNoteIterator;
//    NotationDisplay *d = [NotationDisplay sharedDisplay];
//    d.NumberOfMeasures = 6;
//    float mult = [d getWidthMultiplier:aPiece];
//    
//    
//    
//    rb_traverse(theMeasureIterator, aPiece->measures) {
//        Measure *theMeasure = (Measure *)theMeasureIterator->v.val;
//        rb_traverse(theLineIterator, theMeasure->lines) {
//            Line *theLine = (Line *)theLineIterator->v.val;
//            
//            dl_traverse(theNoteIterator, theLine->l) {
//                Note *theNote = (Note *)theNoteIterator->val;
//                
//                if (theNote->key < 1)
//                    continue;
//                
//                double theOffBeat = theNote->beatoffid;
//                Note *n = theNote->carry;
//                while (n != NULL) {
//                    theOffBeat = n->beatoffid;
//                    n = n->carry;
//                }
//                while (theNote->exmatch != NULL && ((theOffBeat - theNote->beatid) * mult) < 10 && d.NumberOfMeasures > 2) {
//                    d.NumberOfMeasures--;
//                    mult = [d getWidthMultiplier:aPiece];
//                }
//                if (theNote->exmatch != NULL && ((theOffBeat - theNote->beatid) * mult) < 10) {
//                    theNote->draw_as_exmatch = theNote->exmatch->fingerheight;
//                    free(theNote->exmatch);
//                    theNote->exmatch = NULL;
//                    
//                }
//            }
//        }
//    }
//}
//
//+ (void) removeExmatch:(Piece *)aPiece {
//    Rb_node theMeasureIterator, theLineIterator;
//    Dlist theNoteIterator;
//
//    
//    rb_traverse(theMeasureIterator, aPiece->measures) {
//        Measure *theMeasure = (Measure *)theMeasureIterator->v.val;
//        rb_traverse(theLineIterator, theMeasure->lines) {
//            Line *theLine = (Line *)theLineIterator->v.val;
//            
//            dl_traverse(theNoteIterator, theLine->l) {
//                Note *theNote = (Note *)theNoteIterator->val;
//                
//                if (theNote->key < 1)
//                    continue;
//                
//                if (theNote->exmatch != NULL) {
//                    free(theNote->exmatch);
//                    theNote->exmatch = NULL;
//                }
//            }
//        }
//    }
//    
//    aPiece->heights[0] = aPiece->heights[1] = aPiece->qwertyheight = 0;
//
//}
//void put_event_on_buf(Play_state *ps, int dtime, char e1, char e2, char e3, char e4)
//{
////	MidiEvent *mep;
////
////	if (ps->nevents == EVBUF) {
////		mep = (MidiEvent *) malloc(sizeof(MidiEvent)*EVBUF);
////		ps->nevents = 0;
////		dl_insert_b(ps->midi_events, (void *) mep);
////	} else {
////		mep = (MidiEvent *) (ps->midi_events->blink->val);
////	}
////	mep += ps->nevents;
////	if (dtime == -1) {
////		mep->time = 0;
////	} else {
////		mep->time = (dtime - ps->cur_midi_time)*2;
////	}
////	mep->status = e1;
////	mep->data1 = e2;
////	mep->data2 = e3;
////	mep->data3 = e4;
//    
//    //NSLog(@"event on buf");
//	ps->nevents++;
//	ps->total_nevents++;
//   
//	return;
//}
////
////
//- (void) PlayNote:(Note *)n time:(struct timeval *)tv hand:(int)hand
//{
//    int dtime;
//    int key;
//    int newvol;
//    int hap;  /* Hap is either the hand in question (if the hands are apart),
//               or zero (if the hands are together) */
//    Note *n2;
//    Play_state *ps;
//    int prog, bank0, bank32;
//    int newprog;
//    
//    ps = m_PS;
//    ps->last_played = n;
//    
//    
//    /* If the off event for this piece has already happened, do not play it */
//    
//    if (n->playing < 0) { n->playing = 2; return; }
//    
//    n->time = m_PS->current_time;// tv_to_t(tv);
//    hap = hand & ps->mask;
//    
//    /* fprintf(ps->tf, "Playing note %s in M: %d %.3lf\n", n->name, ps->m->number, n->time);
//     fflush(ps->tf);  */
//    
//    if (n->grace_num == 0 && n != ps->trill_note) {
//        if (n->beatid < ps->cbid[hap]) {
//            // fprintf(ps->tf, "Error -- hands out of whack\n");
//        } else if (n->beatid > ps->cbid[hap]) {
//            ps->lbtime[hap] = ps->cbtime[hap];
//            ps->lbid[hap] = ps->cbid[hap];
//            if (ps->mbid[hap] >= 0) {
//                ps->tempo[hap] = (n->beatid-ps->mbid[hap]) / (n->time-ps->mbtime[hap]);
//                // fprintf(ps->tf, "Tempo(%d): %.6lf\n", hap, ps->tempo[hap]);  fflush(ps->tf);
//            }
//            if ((int) n->beatid > (int) ps->cbid[hap]) {
//                // fprintf(ps->tf, "new beat (%d)\n", (int) n->beatid); fflush(ps->tf);
//            }
//            if (ps->m->beatid > ps->mbid[hap]) {
//                ps->mbtime[hap] = n->time - (n->time - ps->mbtime[hap]) *
//                (n->beatid - ps->m->beatid) / (n->beatid - ps->mbid[hap]);
//                ps->mbid[hap] = ps->m->beatid;
//                // fprintf(ps->tf, "New measure %-4d  time = %.6lf\n", ps->m->number, ps->mbtime[hap]);
//            }
//        }
//        
//        ps->cbtime[hap] = n->time;
//       // NSLog(@"cbtime: %f", n->time);
//        ps->cbid[hap] = n->beatid;
//    } else {
//        NSLog(@"skipped");
//    }
//    
//    n->playing = 1;
//    
//    if (n->carry != NULL) {
//        for (n2 = n->carry; n2 != NULL; n2 = n2->carry) n2->playing = 1;
//    }
//    key = n->key;
//    
//    ps->playing[key]++;
//    if (ps->playing[key] == 1) ps->nplaying++;
//    
//    
//    if (!n->phantom) {
//        
//        /* Change program if necessary */
//        
//        dtime = compute_dtime(tv);
//        
//        if (ps->program[n->channel] < 0 || n->program != ps->program[n->channel]) {
//            
//            newprog = (n->program < 0) ? ps->inst_default : n->program;
//            
//            if (newprog != ps->program[n->channel]) {
//                ps->program[n->channel] = newprog;
//                
//                prog = (ps->program[n->channel]%128);
//                bank0 = (ps->program[n->channel]/256)%256;
//                bank32 = (ps->program[n->channel]/256/256);
//                
//                if (bank0 > 0 || bank32 > 0) {
//                    put_event_on_buf(ps, dtime, 0xb0 + n->channel, 0, bank0-1, 0);
//                    ps->cur_midi_time = dtime;
//                    if (bank32 > 0) {
//                        put_event_on_buf(ps, dtime, 0xb0 + n->channel, 32, bank32-1, 0);
//                        ps->cur_midi_time = dtime;
//                    }
//                }
//                put_event_on_buf(ps, dtime, 0xc0 + n->channel, prog, 0, 0);
//                ps->cur_midi_time = dtime;
//                
//                if (bank0 > 0 || bank32 > 0) {
//                    ps->buf[ps->bufptr++] = 0xb0 + n->channel;
//                    ps->buf[ps->bufptr++] = 0;
//                    ps->buf[ps->bufptr++] = bank0-1;
//                    if (bank32 > 0) {
//                        ps->buf[ps->bufptr++] = 0xb0 + n->channel;
//                        ps->buf[ps->bufptr++] = 32;
//                        ps->buf[ps->bufptr++] = bank32-1;
//                    }
//                }
//                ps->buf[ps->bufptr++] = 0xc0 + n->channel;
//                ps->buf[ps->bufptr++] = prog;
//            }
//        }
//        
//        newvol = (n->vol * ps->volperc) / 100;
//        if (newvol > 127) newvol = 127;
//        
//        if(dtime == ps->last_off[key]) { // Put a delay in the midi track buffer if the off and on events for a key coincide.
//            put_event_on_buf(ps, dtime+1, 0x90 + n->channel, key, newvol, 0);
//            if (self.Band && self.MuteBand) {
//                
//            } else {
//                [[AudioPlayer sharedPlayer] playNote:key onChannel:n->channel withVelocity:newvol];
//            }
//        } else {
//            put_event_on_buf(ps, dtime, 0x90 + n->channel, key, newvol, 0);
//            if (self.Band && self.MuteBand) {
//                
//            } else {
//                [[AudioPlayer sharedPlayer] playNote:key onChannel:n->channel withVelocity:newvol];
//            }
//            
//        }
//        
//        ps->cur_midi_time = dtime;
//        if (ps->bufnotes[key] != NULL) {
//            if (*ps->bufnotes[key] > newvol) {
//                n->vol = (*ps->bufnotes[key] * 100) / ps->volperc;
//            } else {
//                *ps->bufnotes[key] = newvol;
//            }
//        } else {
//            // fprintf(ps->tf, "Note on %d channel = %d status will be %02X\n", n->key, n->channel,
//            // 0x90 + n->channel);
//            // fflush(ps->tf);
//            ps->buf[ps->bufptr++] = 0x90 + n->channel;
//            ps->buf[ps->bufptr++] = key;
//            ps->buf[ps->bufptr] = newvol;
//            ps->bufnotes[key] = ps->buf+ps->bufptr;
//            ps->bufptr++;
//            ps->buf[ps->bufptr++] = (ps->last_off[key] == dtime);    // Should there be a delay
//        }
//    }
//    [self DisplayNote:n];
//}
////
//- (void) PassThrough:(Krec_event *)ke
//{
//    int dtime;
//    
//    if (ke->e[0] == 0) return;
//    dtime = compute_dtime(ke->tv);
//    put_event_on_buf(m_PS, dtime, ke->e[0], ke->e[1], ke->e[2], ke->e[3]);
//    m_PS->cur_midi_time = dtime;
//    
//    MidiEvent Evt;
//    Evt.time = 0xFFFFFFFF;
//    Evt.status = ke->e[0];
//    Evt.data1 = ke->e[1];
//    Evt.data2 = ke->e[2];
//    Evt.data3 = ke->e[3];
//   // EchoOut->Put(&Evt);
//}
////
//- (void) FlushBuf
//{
//    int i;
//    MidiEvent Evt;
//    
//    if (DOWRITE) {
//		/* Old code -- this was to write multiple midi events with one
//         write() system call.  ANd it looks to me like this was slightly
//         buggy.  No longer -- Now, I just bundle up each
//         event in a MidiEvent and call PutMidiOut.  I could just do this
//         when I put the stuff into the buffer, but I've decided to minimize
//         changes to my code.  The only events in the buffer are note on (0x90-0x9f),
//         note off (0x80-0x8f) and program change (0xc0-0xcf).  Looks like pedaling
//         is passed through elsewhere.
//         
//         Actually -- there is reason to still do things this way, and that is when
//         you have multiple notes sounding simultaneously. */
//        
//		i = 0;
//		while (i < m_PS->bufptr) {
//			if (m_PS->buf[i] >= 0x80 && m_PS->buf[i] <= 0x9f) {
//				Evt.status = m_PS->buf[i];
//				Evt.data1 = m_PS->buf[i+1];
//				Evt.data2 = m_PS->buf[i+2];
//				m_PS->bufnotes[m_PS->buf[i+1]] = NULL;
//				if (m_PS->buf[i+3]) {
//					Evt.time = 3;  // This does not appear to work.  Drag.
//					// fprintf(m_PS->tf, "Delay put in for key %d\n", m_PS->buf[i+1]);
//				} else {
//					Evt.time = 0XFFFFFFFF;
//				}
//				i += 4;
//			//	EchoOut->Put(&Evt);
//                
//			} else if (m_PS->buf[i] >= 0xc0 && m_PS->buf[i] <= 0xcf) {
//				Evt.time = 0XFFFFFFFF;
//				Evt.status = m_PS->buf[i];
//				Evt.data1 = m_PS->buf[i+1];
//			//	EchoOut->Put(&Evt);
//				i += 2;
//			} else if (m_PS->buf[i] >= 0xb0 && m_PS->buf[i] <= 0xbf) {
//				Evt.time = 0XFFFFFFFF;
//				Evt.status = m_PS->buf[i];
//				Evt.data1 = m_PS->buf[i+1];
//				Evt.data2 = m_PS->buf[i+2];
//			//	EchoOut->Put(&Evt);
//				i += 3;
//			} else {
//				//fprintf(m_PS->tf, "FB ERROR: i = %d, m_PS->buf[i] = %02X  bufptr = %d\n", i,
//               //         m_PS->buf[i], m_PS->bufptr);
//				for (i = 0; i < m_PS->bufptr; i++) {
//					//fprintf(m_PS->tf, "  %02X %d\n", m_PS->buf[i], m_PS->buf[i]);
//				}
//				fflush(m_PS->tf);
//				musplay_error("FlushBuf -- unknown event");
//				exit(1);
//			}
//		}
//        if (i != m_PS->bufptr) {
//            musplay_error("FlushBuf -- i != m_PS->bufptr");
//			exit(1);
//		}
//    }
//    m_PS->bufptr = 0;
//}
////
//- (void) UnplayNote:(Note *)n time:(struct timeval *)tv
//{
//    int dtime;
//    int key;
//    Note *n2;
//    Play_state *ps;
//    
//    ps = m_PS;
//    
//    if (n->playing == 0) {
//        n->playing = -1; //Set the note so that it does not play in the future.
//        return;
//    }
//    
//    /*   printf("Unplaying note %d in M: %d\n", n->key, ps->m->number); */
//    
//    key = n->key;
//    if (key < 0) key = -key;
//    ps->playing[key]--;
//    if (ps->playing[key] == 0 || (bufNoteOff && ps->playing[key] > 0)) {
//        ps->nplaying--;
//        if (!n->phantom) {
//            dtime = compute_dtime(tv);
//            ps->last_off[key] = dtime;
//            put_event_on_buf(ps, dtime, 0x80 + n->channel, key, 64, 0);
//            [[AudioPlayer sharedPlayer] unplayNote:key onChannel:n->channel];
//            ps->cur_midi_time = dtime;
//            /* fprintf(ps->tf, "Note off %d channel = %d status will be %02X\n", n->key, n->channel,
//             0x80 + n->channel);
//             fflush(ps->tf); */
//            
//            /* MidiEvent Evt;
//             Evt.time = 0XFFFFFFFF;
//             Evt.status = 0x80 + n->channel;
//             Evt.data1 = key;
//             Evt.data2 = 64;
//           //  EchoOut->Put(&Evt); */
//            
//            ps->buf[ps->bufptr++] = 0x80 + n->channel;
//            ps->buf[ps->bufptr++] = key;
//            ps->buf[ps->bufptr++] = 64;
//            ps->buf[ps->bufptr++] = 0;  // No delay
//            
//        }
//    }
//    n->playing = 2;
//    for (n2 = n->backcarry; n2 != NULL; n2 = n2->backcarry) {
//        n2->playing = 2;
//    }
//    for (n2 = n->carry; n2 != NULL; n2 = n2->carry) n2->playing = 2;
//    
//    [self DisplayNote:n];
//}
////
////
//- (void) StartNewMeasure:(Measure *)m
//{
//    Rb_node rtmp;
//    Line *l;
//    int ln;
//    Play_state *ps;
//    
//    ps = m_PS;
//    
//    /* If this is not the first measure, then kill the lln entry of any
//     line from the last measure that is not in this measure.  Otherwise,
//     set the endbeat to 0 if the endbeat is currently m->lcm, or -1
//     otherwise */
//    
//    if (ps->m != NULL) {
//        for (ln = 0; ln < ps->p->tlines; ln++) {
//            if (!ps->ison[ln]) {
//                ps->lln[ln].isvalid = 0;
//            } else {
//                if (ps->lln[ln].endbeat == ps->endbeat) {
//                    ps->lln[ln].endbeat = 0;
//                } else {
//                    ps->lln[ln].endbeat = -1;
//                }
//            }
//            ps->ison[ln] = 0;
//        }
//    }
//    
//    
//    /* If we get a bug, it might be here.  More things may have to be
//     set to -1 than tempo and mbid */
//    
//    /* If tempo reset, set both tempos and mbids to -1 */
//    
//    if (!m->use_tempo || m->tempo_reset) {
//        ps->tempo[0] = -1;
//        ps->tempo[1] = -1;
//        ps->mbid[0] = -1;
//        ps->mbid[1] = -1;
//    }
//    
//    /* If apart = 1 and mask = 0, then
//     set tempo et al, and set ps->mask = 1 */
//    
//    if (m->apart && ps->mask == 0) {
//        ps->tempo[1] = ps->tempo[0];
//        ps->cbtime[1] = ps->cbtime[0];
//        ps->cbid[1] = ps->cbid[0];
//        ps->lbtime[1] = ps->lbtime[0];
//        ps->lbid[1] = ps->lbid[0];
//        ps->mbtime[1] = ps->mbtime[0];
//        ps->mbid[1] = ps->mbid[0];
//        ps->mask = 1;
//    } else if (m->apart != ps->mask) {
//        if (ps->cbid[1] > ps->cbid[0]) {
//            ps->cbid[0] = ps->cbid[1];
//            ps->cbtime[0] = ps->cbtime[1];
//            ps->lbid[0] = ps->lbid[1];
//            ps->lbtime[0] = ps->lbtime[1];
//            ps->tempo[0] = ps->tempo[1];
//        }
//        if (ps->mbid[1] > ps->mbid[0]) { /* I haven't thought this through really */
//            ps->cbid[0] = ps->cbid[1];
//            ps->cbtime[0] = ps->cbtime[1];
//            ps->mbid[0] = ps->mbid[1];
//            ps->mbtime[0] = ps->mbtime[1];
//        }
//        ps->mask = 0;
//    }
//    
//    ps->m = m;
//    
//    mins[1] = m->rhkey;
//    maxs[0] = mins[1] - 1;
//    
//    rb_traverse(rtmp, m->lines) {
//        l = (Line *) rtmp->v.val;
//        ln = l->number;
//        if (ln < ps->p->start[TL]) {
//            ps->ison[ln] = 1;
//            ps->lines[ln] = l;
//            ps->lptrs[ln] = l->l->flink;
//            ps->notes[ln] = (Note *) ps->lptrs[ln]->val;
//            ps->cbeat[ln] = 0;
//        }
//    }
//    ps->curbeat[0] = -1;
//    ps->curbeat[1] = -1;
//    ps->beatid[0] = -1;
//    ps->beatid[1] = -1;
//    ps->endbeat = m->meter_num * m->lcm / m->meter_den;
//    
//    if (ps->n_ntp[0] > 0 || ps->n_ntp[1] > 0) {
//        ps->n_ntp[0] = ps->n_ntp[1] = 0;
//       // fprintf(ps->tf, "ERROR: notes to play at the beg. of the measure %d\n",
//               // m->number);
//       // musplay_error("Internal error -- check the trace file");
//    }
//    
//    for (ln = 0; ln < ps->p->tlines; ln++) {
//        [self GoToNextPlayable:ln];
//    }
//}
////
//- (void) ShouldIScroll;
//{
//	Play_state *ps;
//	NotationDisplay *view;
//	int doscroll;
//    
//	ps = m_PS;
//	//view = (CMaxSeqView *) pDoc->GetView();
//    /*	fprintf(ps->tf, "Entering shouldiscroll (%lf)\n", ps->YAH);
//     fflush(ps->tf); */
//    
//	if (ps->firstm == NULL) {  /* I.e. we have not started playing yet */
//		doscroll = 1;
//	} else if (ps->m == NULL) {  /* I.e. there are no more measures to view*/
//		doscroll = 0;
//	} else if (self.NotationDisplay.dlines == 1) {
//		if (ps->lastm == ps->p->measures) {
//			doscroll = 0;
//		} else if (!scroll_penult) {
//			doscroll = (ps->YAH_dmeasure->number >= ps->lastm->k.ikey);
//		} else {
//			doscroll =(ps->YAH_dmeasure->number >= rb_prev(ps->lastm)->k.ikey);
//		}
//	} else if (ps->leftmeasures[1] == NULL) {
//		doscroll = 0;
//	} else if (ps->YAH_dmeasure->number >= ps->leftmeasures[1]->number) {
//		doscroll = 1;
//	} else {
//		doscroll = 0;
//	}
//	if (doscroll) {
//        /*		fprintf(ps->tf, "Entering Scroller\n");
//         fflush(ps->tf); */
//        NSLog(@"scroller");
//		//[self.NotationDisplay Scroller];
//	}
//    /*	fprintf(ps->tf, "Exiting shouldiscroll\n");
//     fflush(ps->tf); */
//    
//}
////
//void bump_line(Play_state *ps,
//               Rb_node rptr,  /* pointer in ps->project[hand] to line */
//               int hand,
//               int inc)
//{
//    int *pkey;
//    int lpkey;
//    int ln;
//    
//    pkey = (int *) rptr->v.val;
//    ln = rptr->k.ikey;
//    while(1) {
//        *pkey += inc;
//        ps->lln[ln].key = *pkey;
//        lpkey = *pkey;
//        rptr = (inc == 1) ? rb_next(rptr) : rb_prev(rptr);
//        if (rptr == ps->project[hand]) return;
//        ln = rptr->k.ikey;
//        pkey = (int *) rptr->v.val;
//        if (*pkey != lpkey) return;
//    }
//}
////
//void correct_projection(Play_state *ps,
//                        Rb_node rptr,   /* pointer in ps->project[hand] to line */
//                        int hand,
//                        int direction,
//                        int key)
//{
//    Rb_node nextr;
//    int ln, nextln, *pkp;
//    int *nextpkey, pkey, tmp;
//    
//    ln = rptr->k.ikey;
//    pkp = (int *) rptr->v.val;
//    pkey = key;
//    *pkp = key;
//    
//    /*
//     printf("\ncorrecting projection %s %d %d %d %d\n\n",
//     ps->lines[ln]->name, pkey, hand, direction, key);
//     printf("Before\n\n");
//     print_play_state(ps);
//     */
//    
//    while(1) {
//        nextr = (direction == 1) ? rb_next(rptr) : rb_prev(rptr);
//        if (nextr == ps->project[hand]) return;
//        nextln = nextr->k.ikey;
//        nextpkey = (int *) nextr->v.val;
//        if (*nextpkey > key && direction == 1) return;
//        if (*nextpkey < key && direction == -1) return;
//        if (*nextpkey == key) {
//            bump_line(ps, nextr, hand, direction);
//            return;
//        } else { /* Otherwise, we have to swap */
//            tmp = pkey; pkey = *nextpkey; *nextpkey = tmp;
//            tmp = ps->lln[nextln].key;
//            ps->lln[nextln].key = ps->lln[ln].key;
//            ps->lln[ln].key = tmp;
//            *pkp = pkey;
//            pkey = *nextpkey;
//            ln = nextln;
//            rptr = nextr;
//            pkp = (int *) rptr->v.val;
//        }
//    }
//}
////
//- (void) MoveGraceNotes:(int)hand
//{
//    Measure *nextm;
//    Rb_node rtmp;
//    int fnd, ln;
//    Note *n;
//    int g;
//    Line *nextl;
//    int done;
//    Dlist dtmp;
//    
//    rtmp = rb_find_ikey_n(m_PS->p->measures, m_PS->m->number+1, &fnd);
//    if (!fnd) return;
//    nextm = (Measure *) rtmp->v.val;
//    
//    /* Find it -- then for each */
//    
//    for (ln = m_PS->p->start[hand]; ln < m_PS->p->start[hand+1]; ln++) {
//        if (m_PS->ison[ln]) {
//            if (m_PS->cbeat[ln] == m_PS->endbeat && m_PS->notes[ln] != NULL) {
//                rtmp = rb_find_key_n(nextm->lines, m_PS->lines[ln]->name, &fnd);
//                if (fnd) {
//                    nextl = (Line *) rtmp->v.val;
//                    n = (Note *) nextl->l->flink->val;
//                    g = n->grace_num;
//                    dtmp = m_PS->lines[ln]->l->blink;
//                    done = 0;
//                    while (!done) {
//                        n = (Note *) dtmp->val;
//                        n->beat_on = 0;
//                        n->beat_off = 0;
//                        n->grace_num = ++g;
//                        dl_insert_a(nextl->l, n);
//                        done = (n == m_PS->notes[ln]);
//                        dtmp = dtmp->blink;
//                    }
//                    while (m_PS->notes[ln] != NULL) {
//                        [self AdvanceLine:ln];
//                        [self GoToNextPlayable:ln];
//                    }
//                }
//            }
//        }
//    }
//}
////
////
//- (void) PlayTies:(Note *)n onoff:(int) onoff event:(Krec_event *)ke hand:(int) hand
//{
//    Dlist dtmp, lst;
//    Note *n2;
//    
//    lst = (onoff) ? n->on_ties : n->off_ties;
//    if (lst == NULL) return;
//    dl_traverse(dtmp, lst) {
//        n2 = (Note *) dtmp->val;
//        if (onoff) {
//            n2->vol = (int) (((double)n->vol) * n2->volperc / 100.0);
//            if (n2->vol > MAXVOL) n2->vol = MAXVOL;
//            if (n2->key > 0) {
//                [self PlayNote:n2 time:ke->tv hand:hand];
//                
//            }
//        } else {
//            if (n2->key != 0) {
//                [self UnplayNote:n2 time:ke->tv];
//               
//            }
//        }
//        [self PlayTies:n2 onoff:onoff event:ke hand:hand];
//       
//    }
//}
////
////
//- (void) KillBeat:(int) hand
//{
//    int ln;
//    Note *n;
//    
//    for (ln = m_PS->p->start[hand]; ln < m_PS->p->start[hand+1]; ln++) {
//        if (m_PS->ison[ln]) {
//            while (m_PS->cbeat[ln] == m_PS->curbeat[hand] && m_PS->notes[ln] != NULL) {
//                
//                /* This is a real hack -- if the note that we're skipping turns
//                 off any ties, turn it off now.  This is not really the right
//                 place to turn it off, but so be it, I don't have time to do
//                 it right */
//                [self PlayTies:m_PS->notes[ln] onoff:0 event:m_PS->k->e hand:hand];
//              
//                n = (Note *) m_PS->notes[ln];
//                if (n->key > 0 && n->playing == 0) {
//                    m_PS->stats[hand].skipped++;
//                }
//                [self AdvanceLine:ln];
//                [self GoToNextPlayable:ln];
//            
//            }
//        }
//    }
//    m_PS->n_ntp[hand] = 0;
//    m_PS->ngrace[hand] = 0;
//}
////
//int is_white(int key)
//{
//	switch (key%12) {
//        case 1:
//        case 3:
//        case 6:
//        case 8:
//        case 10:
//            return 0;
//            break;
//        default:
//            return 1;
//            break;
//	}
//}
////
//int key_color_num(int key) /* numbers white keys and black keys */
//{
//	int inc;
//	int octint;
//	switch (key%12) {
//        case 0: inc = 0; octint = 7; break;
//        case 1: inc = 0; octint = 5; break;
//        case 2: inc = 1; octint = 7; break;
//        case 3: inc = 1; octint = 5; break;
//        case 4: inc = 2; octint = 7; break;
//        case 5: inc = 3; octint = 7; break;
//        case 6: inc = 2; octint = 5; break;
//        case 7: inc = 4; octint = 7; break;
//        case 8: inc = 3; octint = 5; break;
//        case 9: inc = 5; octint = 7; break;
//        case 10: inc = 4; octint = 5; break;
//        default: inc = 6; octint = 7; break;
//	}
//	return key/12*octint + inc;
//}
////
//int is_exmatch(int key, Exmatch *ex, Play_state *ps)
//{
//	int wk1, wk2, diff;
//    if (ps->p->columns) {
//        for (int i = 0; i < 4; i++) {
//            if (ex->colkeys[i] == key)
//                return 1;
//        }
//    }
//	if (key == ex->key) return 1;
//	if (ex->tolerance == 0) return 0;
//	wk1 = is_white(key);
//	wk2 = is_white(ex->key);
//	if (wk1 != wk2) return 0;
//	diff = key_color_num(key) - key_color_num(ex->key);
//	if (diff < 0) diff = -diff;
//	return (diff <= ex->tolerance);
//}
//
//
//int is_adjacent(int key1, int key2)
//{
//	int diff;
//	int white;
//    
//	diff = key1 - key2;
//	if (diff < 0) diff = -diff;
//	if (diff > 2) return 0;
//	white = is_white(key1);
//	
//	if (!white) return (diff == 0);
//    return is_white(key2);
//}
//
//int lacmp(char *s1, char *s2)
//{
//	Note *n1, *n2;
//    
//	n1 = (Note *) s1;
//	n2 = (Note *) s2;
//	if (n1->beatid < n2->beatid) return -1;
//	if (n1->beatid > n2->beatid) return 1;
//	return 0;
//}
////
//- (int) FindRightNote:(Krec_event *)ke /* Returns line number of the note */
//{
//    Rb_node rtmp, bestrptr, rt2;
//    Rb_node latree, latmp;
//    double t, beats, projbegm; /* projbegm = projected beg of next measure */
//    int ln;
//    int hand;           /* 0 for left, 1 for right */
//    int hap;            /* hand & ps->mask */
//    int diff, bestdiff, *pkey, *pkey2, done, exmatches, *lnp;
//    int ts, ok;
//    Note *n;
//    Play_state *ps;
//    
//    ps = m_PS;
//    
//    if (ps->m == NULL) return IGNORE_NOTE;
//    t = tv_to_t(ke->tv);
//    hand = LR(ke->e[1]);
//    hap = hand & ps->mask;
//    
//    /* Check to see if we should be skipping until a certain beat */
//    
//    if (ps->skip_until >= 0) {
//        if (ps->n_ntp[hand] == 0) {
//            [self KillBeat:1-hand];
//            return REDO_EVENT;
//        } else {
//            ok = 1;
//            for (rtmp = rb_first(ps->project[hand]); ok && rtmp != ps->project[hand]; rtmp = rb_next(rtmp)) {
//                ln = rtmp->k.ikey;
//                if (ps->cbeat[ln] == ps->curbeat[hand]) {
//                    n = ps->notes[ln];
//                    if (n->beatid == ps->skip_until) {
//                        ok = 0;
//                        ps->skip_until = -1.0;
//                    } else {
//                        [self KillBeat:hand];
//                        return REDO_EVENT;
//                    }
//                }
//            }
//        }
//    }
//    
//    /* Check for trills first. */
//    
//    if (ps->trill_note != NULL) {
//        for (ts = 0; ts < 2; ts++) {
//            if (ps->trill_key[ts] > 0 && ps->trill_key[ts] == ke->e[1]) {
//                ps->trill_note->trillstate = ts;
//                return TRILL_NOTE;
//            } else if (ps->trill_key[ts] <= 0) {
//                diff = ke->e[1]-ps->trill_key[1-ts];
//                if (diff != 0 && diff <= 2 && diff >= -2) {
//                    ps->trill_key[ts] = ke->e[1];
//                    ps->trill_note->trillstate = ts;
//                    return TRILL_NOTE;
//                }
//            }
//        }
//    }
//    
//    /* If there's no note to play, check and see:
//     1. If the other hand is saying noskip, then you have to ignore this note.
//     2. If we have set noignore, and we can determine that this note does
//     not belong to the previous beat (stray chord note)
//     then we have to go ahead and skip this measure and redo the event
//     3. If we're past what should be the end of the measure, then
//     go ahead and skip this measure and then redo the event to
//     check again.
//     4. Otherwise, ignore this note.  Note, if there is no tempo,
//     then we're either at the beginning of the piece, or at a
//     tempo reset point.  This means that we should ignore this
//     note and wait for one in the other hand.  HERE-FALG
//     */
//    
//    if (ps->n_ntp[hand] == 0) {
//        if (ps->tempo[hap] == -1) { /* 4. */
//            ps->stats[hand].ignored_otherhand++;
//            return IGNORE_NOTE;
//        }
//        if (ps->m->hand[1-hand]->skip == 0) { /* 1. */
//            ps->stats[hand].ignored_otherhand++;
//            return IGNORE_NOTE;
//        }
//        beats = ps->m->beatid + ps->m->meter_num - ps->mbid[hap];
//        projbegm = ps->mbtime[hap] + beats/ps->tempo[hap];
//        /* 3. */
//        if (t+.2 >= projbegm ||
//            (!ps->m->hand[hand]->ignore &&
//             (!ps->m->hand[hand]->chordig || t > ps->cbtime[hap] + 0.10))) {
//                if (ps->curbeat[1-hand] == ps->endbeat) {
//                    /* Only grace notes left */
//                    [self MoveGraceNotes:1-hand];
//                }
//                [self KillBeat:1-hand];
//                return REDO_EVENT;
//                /* 4. */
//            } else {
//                ps->stats[hand].ignored_otherhand++;
//                return IGNORE_NOTE;
//            }
//    }
//    
//    /* If our hands are out of whack (i.e. there is a note to play in the
//     other hand,
//     but not in this hand, and we're supposed to be playing together) then:
//     1. If the other hand is saying noskip, then you have to ignore this note.
//     2. If this is a reasonable time to play the note, or we're not allowed
//     to ignore notes and we can determine that this note does
//     not belong to the previous beat (stray chord note),
//     kill the other hand's beat, and redo the event.
//     3. If this is past a reasonable time for the other hand's note to
//     be played, then kill the other hand's beat and redo the event.
//     4. Otherwise, ignore this note
//     
//     It would appear to me that if the tempo is -1 (i.e. beginning of
//     piece, or tempo reset, then it automatically skips the other hand's
//     stuff and plays this hand's notes)
//     */
//    
//    if (!ps->m->apart && ps->ngrace[hand] == 0 &&
//        ps->curbeat[hand] > ps->curbeat[1-hand]) {
//        /* 1. */
//        if (ps->m->hand[1-hand]->skip == 0) {
//            ps->stats[hand].ignored_otherhand++;
//            return IGNORE_NOTE;
//        }
//        beats = ps->beatid[hand] - ps->mbid[hap];
//        projbegm = ps->mbtime[hap] + beats/ps->tempo[hap];
//        /* 2. */
//        if (t+.2 >= projbegm ||
//            (!ps->m->hand[hand]->ignore &&
//             (!ps->m->hand[hand]->chordig || t > ps->cbtime[hap] + 0.10))) {
//                [self KillBeat:1-hand];
//                return REDO_EVENT;
//            } else {
//                beats = ps->beatid[1-hand] - ps->mbid[hap];
//                projbegm = ps->mbtime[hap] + beats/ps->tempo[hap];
//                /* 3. */
//                if (t-.15 >= projbegm) {
//                      [self KillBeat:1-hand];
//                    return REDO_EVENT;
//                    /* 4. */
//                } else {
//                    ps->stats[hand].ignored_otherhand++;
//                    return IGNORE_NOTE;
//                }
//            }
//    }
//    
//    /* If this note belongs on the last beat, (i.e. it is a stray note
//     from the previous chord) ignore it -- it's a mistake.  Note that
//     if tempo is -1, (beginning of piece, or tempo reset), then
//     the note should get played. */
//    
//    rtmp = rb_first(ps->project[hand]);
//    n = (Note *) rtmp->v.val;
//    
//    beats = ps->beatid[hand] - ps->mbid[hap];
//    projbegm = ps->mbtime[hap] + beats/ps->tempo[hap];
//    
//    //NSLog(@"t = %f", t);
//    
//    /* I'm still confused about all this...
//     
//     
//     
//     if (t-0.00001 > projbegm && t - ps->cbtime[hap]+0.00001 < n->mininterspace) {
//     fprintf(ps->tf, "%lf %lf %lf %lf %lf %lf\n", beats, n->mininterspace,
//     t, ps->cbtime[hap], t-ps->cbtime[hap], projbegm);
//     fprintf(ps->tf, "I would ignore this note. Ignoring\n");
//     //	  return IGNORE_NOTE;
//     } */
//    
//    /* Double check?  I should mess with this more. */
//    //NSLog(@"%f", ps->cbtime[hap]);
////    if (t - ps->cbtime[hap] < .10) {
////        if (t + .2 < projbegm) {
////            ps->stats[hand].ignored_otherhand++;
////           // NSLog(@"no time: %f %f", ps->cbtime[hap], t);
////            return IGNORE_NOTE;
////        }
////    }
//    
//    /* Now, scan the lines first for exmatches.  If any have exmatches, then we're going
//     to ignore the note if it doesn't match any notes. Or -- we have to check for lookahaed. */
//    
//    exmatches = 0;
//    
//    for (rtmp = rb_first(ps->project[hand]); rtmp != ps->project[hand]; rtmp = rb_next(rtmp)) {
//        ln = rtmp->k.ikey;
//        if (ps->cbeat[ln] == ps->curbeat[hand]) {
//            n = ps->notes[ln];
//            if (n->exmatch != NULL) {
//                exmatches++;
//                if (is_exmatch(ke->e[1], n->exmatch, ps)) {
//                    ps->lln[ln].isvalid = 1;
//                    ps->lln[ln].key = ke->e[1];
//                    ps->lln[ln].endbeat = n->beat_off;
//                    ps->stats[hand].played++;
//                    return ln;
//                }
//            } else {
//                exmatches -= 10000000;
//            }
//        }
//    }
//    
//    if (exmatches > 0) {
//        latree = make_rb();
//        for (rtmp = rb_first(ps->project[hand]); rtmp != ps->project[hand]; rtmp = rb_next(rtmp)) {
//            ln = rtmp->k.ikey;
//            if (ps->cbeat[ln] == ps->curbeat[hand]) {
//                n = ps->notes[ln];
//                if (n->exmatch != NULL && n->lookahead > 0 && n->exmatch->lookahead != NULL) {
//                    ps->nlookaheadtmp[ln] = n->lookahead;
//                    rb_insertg(latree, (char *) n->exmatch->lookahead,
//                               (void *)&(ps->nlookaheadtmp[ln]), lacmp);
//                }
//            }
//        }
//        while(!rb_empty(latree)) {
//            latmp = rb_first(latree);
//            n = (Note *) latmp->k.key;
//            lnp = (int *) latmp->v.val;
//            ln = *lnp;
//            rb_delete_node(latmp);
//            if (is_exmatch(ke->e[1], n->exmatch, ps)) {
//                ps->skip_until = n->beatid;
//                  [self KillBeat:hand];
//                rb_free_tree(latree);
//                return REDO_EVENT;
//            } else {
//                ps->nlookaheadtmp[ln]--;
//                if (ps->nlookaheadtmp[ln] > n->lookahead) ps->nlookaheadtmp[ln] = n->lookahead;
//                if (ps->nlookaheadtmp[ln] > 0 && n->exmatch->lookahead != NULL) {
//                    rb_insertg(latree, (char *) n->exmatch->lookahead,
//                               (void *)&(ps->nlookaheadtmp[ln]), lacmp);
//                }
//            }
//        }
//        rb_free_tree(latree);
//        ps->stats[hand].ignored_exmatch++;
//        return IGNORE_NOTE;
//    }
//    
//    /* I'm not sure what to do about non-adjacent when there are multiple notes per beat.
//     For now, I'm just going to find the best line, and then check the adjacent note issue.
//	 This might not be right, but perhaps I'll fix it later. */
//    
//    /* Now, find the best playable line with a projection closest to
//     the played note */
//    
//    done = 0;
//    bestdiff = 1000;
//    for (rtmp = rb_first(ps->project[hand]); !done && rtmp != ps->project[hand];
//         rtmp = rb_next(rtmp)) {
//        ln = rtmp->k.ikey;
//        if (ps->notes[ln] == NULL || ps->notes[ln]->exmatch != NULL) {
//            continue;
//        }
//        if (ps->cbeat[ln] == ps->curbeat[hand]) {
//            pkey = (int *) rtmp->v.val;
//            diff = (*pkey - ke->e[1]);
//            done = (diff >= 0);
//            if (diff < 0) diff = -diff;
//            if (diff < bestdiff) {
//                bestrptr = rtmp;
//                bestdiff = diff;
//            } else if (diff == bestdiff) {  /* Resolve ties */
//                if (rb_next(bestrptr) == rtmp) {  /* Both have no conflicts */
//                    if (hand == RIGHT) {  /* tie goes up for right, down for left */
//                        bestrptr = rtmp;
//                        bestdiff = diff;
//                    }
//                } else {  /* There is a conflict somewhere -- find it */
//                    rt2 = rb_next(bestrptr);
//                    pkey2 = (int *) rt2->v.val;
//                    if (*pkey2 <= ke->e[1]) {  /* conflict for low note -- go with high */
//                        bestrptr = rtmp;
//                        bestdiff = diff;
//                    }                       /* otherwise go with low note */
//                }
//            }
//        }
//    }
//    if (bestdiff == 1000) {
//        return IGNORE_NOTE;
//        fprintf(ps->tf, "Error: M: %d hand %d beat %d:", ps->m->number,
//                hand, ps->curbeat[hand]);
//        fprintf(ps->tf, " no note to match, but ntp = %d\n",
//                ps->n_ntp[hand]);
//        musplay_error("Internal error -- check the trace file");
//    }
//    
//    /* Ok -- bestptr is the rb-tree pointer to the best fitting line.
//     We will return this.  However, if there are conflicts, we have
//     to fix them in lln[].  This means that the key pressed may map
//     to a different note in the lln[] entry, but we're going to
//     play the note we found.  */
//    
//    pkey = (int *) bestrptr->v.val;
//    ln = bestrptr->k.ikey;
//    diff = (*pkey - ke->e[1]);
//    
//    /* If a note has already been played on this beat, and there are
//     more to play on this beat, then they must start within 0.15 seconds
//     of the last note played on this beat.  Exceptions to this are
//     1. The note is a grace note
//     2. Chordig is false (so you play it whenever)
//     3. Skip is false and no notes have been played by this hand yet.
//     4. It's a ripple -- you get .3 seconds to play a ripple
//     */
//    
//    if (ps->notes[ln]->dur_num > 0 && ps->beatid[hand] == ps->cbid[hap] &&
//        ps->m->hand[hand]->chordig &&
//        (ps->m->hand[hand]->skip || (ps->lhp[hand] == ps->cbid[hap]))) {
//        if (!ps->rippling[hand] && t > ps->cbtime[hap] + 0.15 ||
//            t > ps->cbtime[hap] + 0.3) {
//              [self KillBeat:hand];
//            return REDO_EVENT;
//        }
//    }
//    
//    /* Now, if we're rippling this hand, then we need to ignore the line
//     that we found and simply go with the lowest playable note.  The only
//     exception to this is if we're playing a grace note.  If it's a grace
//     note, play it.  Otherwise, correct it. */
//    
//    if (ps->notes[ln]->dur_num > 0 && ps->rippling[hand]) {
//        done = 0;
//        bestdiff = 1000;
//        for (rtmp = rb_first(ps->project[hand]); !done && rtmp != ps->project[hand];
//             rtmp = rb_next(rtmp)) {
//            ln = rtmp->k.ikey;
//            if (ps->cbeat[ln] == ps->curbeat[hand]) {
//                pkey = (int *) rtmp->v.val;
//                diff = (*pkey - ke->e[1]);
//                done = 1;
//                bestrptr = rtmp;
//            }
//        }
//        if (!done) {
//            fprintf(ps->tf, "Serious error #AAA -- M: %d\n", ps->m->number);
//            musplay_error("Internal error -- check the trace file");
//        }
//    }
//    
//    /* ok -- this might not be right, but it is here that I'm going to check for adjacency,
//     and if we've matched an adjacent note and we shouldn't have, I'm going to ignore it.
//	 I don't think I've done any damage at this point.  For stat purposes, I'm going to
//	 log this as an exmatch miss, since it is similar.
//     */
//    
//    if (ps->notes[ln]->noadjacent && ps->lln[ln].isvalid &&
//        is_adjacent(ps->lln[ln].key, ke->e[1])) {
//        ps->stats[hand].ignored_exmatch++;
//        return IGNORE_NOTE;
//    }
//    
//    /* Otherwise, we've finally found a match -- return it */
//    
//    ps->lln[ln].isvalid = 1;
//    ps->lln[ln].key = ke->e[1];
//    ps->lln[ln].endbeat = ps->notes[ln]->beat_off;
//    
//    if (diff < 0) {
//        correct_projection(ps, bestrptr, hand, 1, ke->e[1]);
//    } else if (diff > 0) {
//        correct_projection(ps, bestrptr, hand, -1, ke->e[1]);
//    }
//    ps->stats[hand].played++;
//    return ln;
//}
////
//- (void) SetUpProjections:(int) hand
//{
//    play_state *ps;
//    int ln, *lnp;
//    Rb_node tmp, tmptree, tabove, tbelow;
//    int pkey, *pkp, minrange, maxrange;
//    int done;
//    Note *n;
//    
//    ps = m_PS;
//    
//    /* No notes to play on the current beat.  Find the current beat */
//    if (ps->n_ntp[hand] > 0) return;
//    
//    ps->curbeat[hand] = ps->endbeat;
//    ps->nnotes[hand] = 0;
//    for (ln = ps->p->start[hand]; ln < ps->p->start[hand+1]; ln++) {
//        if (ps->ison[ln]) {
//            if (ps->cbeat[ln] < ps->curbeat[hand]) {
//                ps->curbeat[hand] = ps->cbeat[ln];
//                ps->beatid[hand] = ps->notes[ln]->beatid;
//            }
//            if (ps->notes[ln] != NULL) ps->nnotes[hand] = 1;
//        }
//    }
//    /* Now, if there are notes to play, set up n_ntp */
//    if (ps->nnotes[hand]) {
//        ps->rippling[hand] = 0;
//        for (ln = ps->p->start[hand]; ln < ps->p->start[hand+1]; ln++) {
//            if (ps->ison[ln] && ps->cbeat[ln] == ps->curbeat[hand] && ps->notes[ln] != NULL) {
//                if (ps->notes[ln]->ripple > 0) ps->rippling[hand] = 1;
//                ps->n_ntp[hand]++;
//                if (ps->notes[ln]->grace_num > 0) ps->ngrace[ln]++;
//            }
//        }
//    }
//    
//    if(ps->n_ntp[hand] > 0) {
//        
//        /* kill current projections */
//        while (!rb_empty(ps->project[hand])) {
//            tmp = rb_first(ps->project[hand]);
//            free(tmp->v.val);
//            rb_delete_node(tmp);
//        }
//        
//        /* First, sort all notes that are either in the process of
//         being played, or that have to be played by their ending beat.
//         We will run through this list backwards, inserting projections.
//         What this means is that the first projections will be for notes
//         that are being played.  Then those that were played recently.
//         Then those that were played less recently.  If a note has a
//         hint, then it is inserted into the back of the tree by
//         using ps->m->lcm + 1.  If this is the first time that we are
//         seeing the note from this line (or if the line has been inactive
//         for more than a measure), then we put it on the front of the tree
//         so that it gets processed last.  */
//        
//        tmptree = make_rb();
//        for (ln = ps->p->start[hand]; ln < ps->p->start[hand+1]; ln++) {
//            if (ps->ison[ln]) {
//                lnp = (int *)malloc(sizeof(int));
//                *lnp = ln;
//                if (ps->lln[ln].isvalid && ps->lln[ln].endbeat > ps->curbeat[hand]) {
//                    // The note is currently playing
//                    rb_inserti(tmptree, ps->lln[ln].endbeat, lnp);
//                } else if (ps->cbeat[ln] == ps->curbeat[hand]) {
//                    // The note is going to be played on this beat.
//                    if (ps->notes[ln]->hint != NULL) {
//                        // There is a hint -- put this on the back of the tree
//                        rb_inserti(tmptree, ps->m->lcm * ps->m->meter_num / ps->m->meter_den + 1, lnp);
//                    } else if (ps->lln[ln].isvalid) {
//                        // A note has been played before that we can use to project.
//                        rb_inserti(tmptree, ps->lln[ln].endbeat, lnp);
//                    } else {
//                        // We're shooting blind -- put this at the front.
//                        rb_inserti(tmptree, -ps->m->lcm, lnp);
//                    }
//                }
//            }
//        }
//        
//        /* Now, run through this list backwards, inserting projections into
//         the projection list.  If there are problems to be resolved, then
//         resolve them.  */
//        
//        while(!rb_empty(tmptree)) {
//            tmp = rb_last(tmptree);
//            lnp = (int *) tmp->v.val;
//            ln = *lnp;
//            free(lnp);
//            rb_delete_node(tmp);
//            if (ps->lln[ln].isvalid) {
//                pkey = ps->lln[ln].key;
//                if (pkey > maxs[hand]) pkey = maxs[hand];
//                if (pkey < mins[hand]) pkey = mins[hand];
//            } else {
//                pkey = -1;
//            }
//            
//            /* Find the range for this line */
//            
//            tabove = rb_find_ikey(ps->project[hand], ln);
//            if (tabove == ps->project[hand]) {
//                maxrange = maxs[hand]+1;
//            } else {
//                pkp = (int *) tabove->v.val;
//                maxrange = *pkp;
//            }
//            tbelow = rb_prev(tabove);
//            if (tbelow == ps->project[hand]) {
//                minrange = mins[hand]-1;
//            } else {
//                pkp = (int *) tbelow->v.val;
//                minrange = *pkp;
//            }
//            
//            /* If the range is nothing, make some room */
//            if (maxrange - minrange < 1) {
//                fprintf(ps->tf, "Internal Error: m: %d beat %d hand %d maxrange - minrange = %d\n",
//                        ps->m, ps->curbeat[hand], hand, maxrange-minrange);
//                musplay_error("Internal error: check the trace file");
//            }
//            
//            if (maxrange - minrange == 1) {
//                if (tabove == ps->project[hand]) {
//                    bump_line(ps, tbelow, hand, -1);
//                    minrange--;
//                } else if (tbelow == ps->project[hand]) {
//                    bump_line(ps, tabove, hand, 1);
//                    maxrange++;
//                } else if (maxs[hand] - maxrange > minrange - mins[hand]) {
//                    bump_line(ps, tabove, hand, 1);
//                    maxrange++;
//                } else {
//                    bump_line(ps, tbelow, hand, -1);
//                    minrange--;
//                }
//            }
//            
//            // Error check to make sure it all went ok.
//            if (maxrange - minrange <= 1) {
//                fprintf(ps->tf, "Error: M: %d hand %d beat %d:", ps->m->number,
//                        hand, ps->curbeat[hand]);
//                fprintf(ps->tf, "This shouldn't happen! %d %d\n",
//                        minrange, maxrange);
//                musplay_error("Internal error -- check the trace file");
//            }
//            
//            /* Now -- set projections according to the following order:
//             If there is a note to play and it has a hint, then try to use the
//             hint.  If you can't, then use the pkey value, which is the last key
//             played for that line.  If there is no pkey value, then use the note
//             itself if it fits, and finally, if you can't do any of these, simply
//             split the range in half.  */
//            
//            n = (ps->cbeat[ln] == ps->curbeat[hand]) ? ps->notes[ln] : NULL;
//            
//            done = 0;
//            if (n != NULL && n->hint != NULL) {
//                if (n->hint->key < maxrange && n->hint->key > minrange) {
//                    pkey = n->hint->key;
//                    done = 1;
//                }
//            }
//            
//            if (!done && pkey == -1) { // n will not be NULL here -- error check to be sure.
//                if (n == NULL) {
//                    fprintf(ps->tf, "M: %d H: %d L: %s -- pkey == -1, but n == NULL\n",
//                            ps->m->number, hand, ps->lines[ln]->name);
//                    musplay_error("Internal error -- check the trace file");
//                }
//                // If the note's key fits (and it's not a phantom), use it
//                if (!n->phantom && n->key > minrange && n->key < maxrange) {
//                    pkey = n->key;
//                    done = 1;
//                    // Otherwise, split the range.
//                } else {
//                    pkey = (maxrange + minrange) / 2;
//                    done = 1;
//                }
//            }
//            
//            /* If the line fits nicely, just use pkey */
//            if (!done && pkey > minrange && pkey < maxrange) done = 1;
//            
//            /* Otherwise, this should be a line whose last note
//             ended before this beat, and this last note doesn't fit here.
//             Make it fit -- do this depending on what minrange,maxrange is. */
//            
//            if (!done) {
//                if (maxrange - minrange >= 7) {
//                    pkey = (pkey <= minrange) ? minrange + 4 : maxrange - 4;
//                    done = 1;
//                } else  {
//                    pkey = (maxrange + minrange) / 2;
//                    done = 1;
//                }
//            }
//            
//            ps->lln[ln].key = pkey;
//            pkp =  (int *)malloc(sizeof(int));
//            *pkp = pkey;
//            rb_inserti(ps->project[hand], ln, pkp);
//        }
//        rb_free_tree(tmptree);
//    }
//}
////
//- (int) PlayMeasureStart /* This sets things up so that we're ready
//                                  to receive events.  It returns 1 if 
//                                  everything is ok.  It returns 0 if the
//                                  piece is over. */
//{
//	Measure *m;
//    
//	while (1) {
//		if (m_PS->m == NULL) {  /* No more notes to play -- just wait for note off */
//			if (m_PS->nplaying == 0) {
//                if (self.Band) {
//                    [[NotationDisplay bandPlayer] finishPiece];
//                } else {
//                [[NotationDisplay sharedDisplay] finishPiece];
//                }
//           
//				[self FinishPiece];
//                if (!self.Band) {
//                    [[InputHandler bandHandler] FinishPiece];
//                }
//				return 0;
//			}
//			return 1;
//		} else {
//			[self SetUpProjections:LH];
//			[self SetUpProjections:RH];
//			// print_play_state(m_PS);
//			if (!m_PS->nnotes[0] && !m_PS->nnotes[1]) { /* move on to the next measure */
//				m_PS->m_ptr = rb_next(m_PS->m_ptr);
//				if (m_PS->m_ptr == m_PS->p->measures) {
//					m_PS->m = NULL;
//				} else {
//					m = (Measure *) m_PS->m_ptr->v.val;
//					[self StartNewMeasure:m];  /* This sets m_PS->m */
//				}
//			} else {
//				return 1;
//			}
//		}
//	}
//}
//
//- (int) PlayMeasure:(LPMIDIEVENT)lpMsg
//{
//    /* We expect the lines to all be ready -- i.e. on notes or NULL */
//    int ln, lr, i;
//    Krec_event *ke;
//    Note *n;
//    int redo;
//    play_state *ps;
//    
//    ps = m_PS;
//    
//    redo = 0;
//    while(1) {
//        ke = krec_event(ps->k, lpMsg, ps->one_back, [Synchronizer sharedSynchronizer].beats, [[Synchronizer sharedSynchronizer] tempo], ps->base_clock_time);
//        
//        /* Trace It */
//        /* if (ke->e[0] != 0xf8) {
//         fprintf(ps->tf, "%4d %4d.%06d: %02X %3d", redo, ke->tv->tv_sec, ke->tv->tv_usec, ke->e[0], ke->e[1]);
//         if (KE_NOTE_ON(ke) || KE_NOTE_OFF(ke)) {
//         fprintf(ps->tf, " %3d", ke->e[2]);
//         }
//         fprintf(ps->tf, "\n"); fflush(ps->tf);
//         }  */
//        
//        redo = 0;
//        if (KE_NOTE_ON(ke)) {
//            ln = [self FindRightNote:ke];   /* Line number of note to play --
//                                       this sets up lln correctly */
//            
//            if (ln == IGNORE_NOTE) {
//               // NSLog(@"ignore");
//                ps->mapped[ke->e[1]] = Note_Ignore;
//            } else if (ln == REDO_EVENT) {
//                 NSLog(@"redo");
//                krec_undo(ps->k);
//                lpMsg = NULL;
//                redo = 1;
//            } else {
//                lr = LR(ke->e[1]);
//                if (ln == TRILL_NOTE) {
//                    n = ps->trill_note;
//                    if (n->trillstate == 1) n = n->trillnote;
//                } else {
//                    n = ps->notes[ln];
//                }
//                n->vol = (int) (ke->e[2]*n->volperc/100.0);
//                if (n->vol > 127) n->vol = 127;
//                if (!self.Band) {
//                 NSLog(@"%f -- %f", n->beatid, ps->YAH);
//                if (!self.Band && n->beatid - self.PS->YAH > 10) {
//                    return 0;
//                }
//                }
//                [self PlayNote:n time:ke->tv hand:lr];
//               
//                ps->lhp[lr] = ps->cbid[lr&ps->mask];
//                ps->lhpt[lr] = ps->cbtime[lr&ps->mask];
//                if (ps->mapped[ke->e[1]] != NULL) {
//                    fprintf(ps->tf, "Internal error: M: %d beat %f:",
//                            ps->m->number, ps->curbeat);
//                    fprintf(ps->tf, "note on before note off %d -- trying to continue?\n", ke->e[1]);
//                    /* musplay_error("Internal error -- check the trace file"); */
//                }
//                ps->mapped[ke->e[1]] = (ln == TRILL_NOTE) ? n : n->carrytc;
//                [self PlayTies:n onoff:1 event:ke hand:lr];
//                [self FlushBuf];
//                if (n->grace_num > 0) ps->ngrace[ln]--;
//                if (ln != TRILL_NOTE) {
//                    ps->n_ntp[lr]--;
//                    if (ps->trill_note != NULL && ps->trill_line == ln) {
//                        ps->trill_note = NULL;
//                        ps->trill_key[0] = -1;
//                        ps->trill_key[1] = -1;
//                    }
//                    if (n->trill) {
//                        ps->trill_note = n;
//                        ps->trill_key[0] = ke->e[1];
//                        ps->trill_key[1] = -1;
//                        ps->trill_line = ln;
//                    }
//                    [self AdvanceLine:ln];
//                    [self GoToNextPlayable:ln];
//                    if (ps->cbeat[ln] == ps->curbeat[lr] && 
//                        ps->notes[ln] != NULL &&
//                        ps->notes[ln]->beat_on == ps->cbeat[ln]) { /* Grace note */
//                        ps->n_ntp[lr]++;
//                        if (ps->notes[ln]->grace_num > 0) ps->ngrace[ln]++;
//                    }
//                } else {
//                    ps->trill_note->trillstate = 0;
//                }
//            }
//        } else if (KE_NOTE_OFF(ke)) {
//            if (ps->mapped[ke->e[1]] == NULL) {
////                fprintf(ps->tf, "Internal error: M: %d beat %d:",
////                        ps->m->number, ps->curbeat[LR(ke->e[1])]);
////                fprintf(ps->tf, "note off without note on %d -- ignoring the event\n", ke->e[1]);
//                /* musplay_error("Internal error -- check the trace file"); */
//            } else if (ps->mapped[ke->e[1]] == Note_Ignore) {
//                /* ignore the note */
//            } else {
//                lr = LR(ke->e[1]);
//                n = ps->mapped[ke->e[1]];
//                [self UnplayNote:n time:ke->tv];
//                [self PlayTies:n onoff:0 event:ke hand:lr];
//                [self FlushBuf];
//              
//            }
//            ps->mapped[ke->e[1]] = NULL;
//        } else if (KE_CONTROL(ke)) {
//            if (KE_PEDAL_DOWN(ke)) {
//                ps->nplaying++;
//            } else if (KE_PEDAL_UP(ke)) {
//                ps->nplaying--;
//            }
//            [self PassThrough:ke];
//        } else if (ke->e[0] != 0xf8 && ke->e[0] != 0) {
//            [self PassThrough:ke];
//        }
//        
//        i = [self PlayMeasureStart];
//        if (!redo) return 1;
//    }
//}
//
//- (void)processBeat:(int)beat {
//    [self ProcessBeat:beat];
//}
////
//- (void) ProcessBeat:(int)beats
//{
//	//CMaxSeqView *view;
//	Play_state *ps;
//	double newyah;
//    
//	ps = m_PS;
//	//view = (CMaxSeqView *) pDoc->GetView();
//    struct timeval tv;
//    gettimeofday(&tv, NULL);
//	ps->current_time = (double)(tv_to_t(&tv)*CLOCKS_PER_SEC - ps->base_clock_time)/(double)CLOCKS_PER_SEC;
//	newyah = [self.NotationDisplay CalcYAH:m_PS];
//  //  NSLog(@"%f", newyah);
////
////    NSLog(@"%ld", tv.tv_sec);
//    
//    if (self.Band) {
//        NSLog(@"band");
//    }
//    if (ps->p->bandplay) {
//        [[NotationDisplay bandPlayer] Autoplay:(newyah)];
//    }
//	if (ps->p->autoplay) {
//        [[NotationDisplay sharedDisplay] Autoplay:-1000];
//    }
//	if (newyah != ps->YAH) {
//		[self DeleteYAH:1];
//		ps->YAH = newyah;
//        [self DisplayYAH:1];
//		[self ShouldIScroll];
//    }
//}
////
//
//- (void)prepareToPlay:(Piece *)aPiece {
//    //CDialogErrbox ebox;
//	int i;
//	Rb_node rtmp;
//	Measure *m;
//    [self FinishPiece];
//    //[[Synchronizer sharedSynchronizer] restart];
//
//    
//	//ebox.m_strErrstring = "";
//    p = aPiece;
//	if (p == NULL) {
//        return;
//    }
//        //ebox.m_strErrstring = "No Mus File";
////        rb_free_tree(display_notes);
////	display_notes = make_rb();
//    //	if (Sync->IsRecording()) ebox.m_strErrstring = "Cannot start playing the piece while you are recording MIDI";
//    //	if (Sync->IsPlaying()) ebox.m_strErrstring = "Cannot start playing the piece while you are playing MIDI";
//    //	if (ebox.m_strErrstring.GetLength() > 0) {
//    //		i = ebox.DoModal();
//    //		return;
//    //	}
//    //	MidiIn.pDoc = GetDocument();
//    //	MidiIn.StopNote = StopNote;
//    //	MidiIn.StopWheel = StopWheel;
//    //	MidiIn.StopF0 = StopF0;
//    //	MidiIn.scroll_penult = scroll_penult;
//    //	MidiIn.bufNoteOff = bufNoteOff;
//        if (rb_empty(aPiece->measures)) {
//			m_SM = 1;
//		} else {
//			m = (Measure *) rb_first(aPiece->measures)->v.val;
//			m_SM = m->number;
//		}
//    	rtmp = rb_find_ikey(p->measures, m_SM);
//    	if (rtmp == p->measures) rtmp = rb_first(p->measures);
//    	m = (Measure *) rtmp->v.val;
//    [self StartCmp:p measure:m->number];
//    	//    	[self Invalidate];
//    if (!self.Band) {
//        [self.NotationDisplay DrawMeasures];
//    }
//}
//- (void) StartCmp:(Piece *)aPiece measure:(int) start_measure
//{
//    Measure *m;
//    int i;
//   // CMaxSeqView *view;
//    int tempo;
//    
//  //  view = (CMaxSeqView *) pDoc->GetView();
//    ignore_keyboard = aPiece->autoplay;
//    [self InitPlayState:aPiece];
//    if (self.Band) {
//        [NotationDisplay bandPlayer].PS = m_PS;
//        [NotationDisplay bandPlayer].p = aPiece;
//    } else {
//    self.NotationDisplay.PS = m_PS;
//    self.NotationDisplay.p = aPiece;
//    }
//    
////    if (inst >= 0) m_PS->inst_default = inst;
////    synchronizer = sync;
////    
////    // sync must be started before any data is sent
////    // to midi out so that data is sent with proper timing.
////    
////    tempo = 50000;
//////    Sync->Tempo(tempo);
//////    Sync->beats = 0;
//////    Sync->IsCmping(TRUE);
//////    Sync->Start();
//    struct timeval tv;
//    gettimeofday(&tv, NULL);
//    m_PS->base_clock_time = tv_to_t(&tv)*CLOCKS_PER_SEC;
//    m_PS->last_clock = m_PS->base_clock_time;
//    
//    m_PS->m_ptr = rb_find_ikey(p->measures, start_measure);
//    if (m_PS->m_ptr == p->measures) {   /* This should never happen */
//        [self FinishPiece];
//        return; 
//    }
//    
//    m = (Measure *) m_PS->m_ptr->v.val;
//    [self StartNewMeasure:m];  /* This sets m_PS->m */
//    i = [self PlayMeasureStart];
//    if (self.Band) {
//        [[NotationDisplay bandPlayer] prepareToPlay];
//    } else {
//    [[NotationDisplay sharedDisplay] prepareToPlay];
//    }
//    [self ShouldIScroll];
//    
//    
//}
////
////
////
@end
