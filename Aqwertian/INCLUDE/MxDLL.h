//-----------------------------------------------------------------------------
// Maximum MIDI Programmer's ToolKit
// 32-bit App Header File
//
// Copyright (c) Paul A. Messick, 1994-1996
//
// Written by Paul A. Messick
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//	Definitions
//-----------------------------------------------------------------------------
#include <mmsystem.h>
#include "MaxMidi.h"

#ifdef WIN32
#define PREFIX __declspec(dllexport)
#define EXPORT
#define FreeGlobalMem16(gMem) GlobalFree(GlobalHandle(gMem))
#define SELECTOROF(x) x
#else
#define PREFIX
//#define EXPORT _export
#endif

#ifdef __cplusplus
extern "C" {            // Assume C declarations for C++
#endif

#define MIDIINCLASS "MaxMidiInClass"
#define MIDIOUTCLASS "MaxMidiOutClass"
#define WINDOWS_QUEUE_SIZE 64
#define SCALE 256L

#define QMASK  0x0000F000L
#define SXMASK 0x00000F00L
#define NMASK  0x000000FFL

//	flag bit definations
//	internal flags
#define MIDI_IN_INTERNAL	0x000FFFFFL
#define MIDI_IN_STARTED		0x00100000L
#define MIDI_OUT_INTERNAL	0x000FFFFFL
#define SENDING_SYSEX		0x00200000L
#define SYNC_ENABLED		0x0001
#define SYNC_RUNNING		0x0002
#define IN_SYNC				0x0008
#define MC_HOLD				0x0010
#define	MC_RESYNC			0x0020
#define SENT_SYNCDONE		0x0040
#define RUNNING_STATUS		0x0080

// smf internals
#define META_SEQUENCE_NUMBER_LENGTH	2
#define META_CHAN_PREFIX_LENGTH		1
#define META_EOT_LENGTH				0
#define	META_TEMPO_LENGTH			3
#define META_SMPTE_OFFSET_LENGTH	5
#define	META_TIME_SIG_LENGTH		4
#define	META_KEY_SIG_LENGTH			2

#define SMF_HEADER_SIZE				6L

#pragma pack(1)
//-----------------------------------------------------------------------------
//	Midi In Definitions
//-----------------------------------------------------------------------------
typedef struct {
	HWND		hWnd;			// handle to the window that will receive MIM_... messages
	HMIDIIN		hMidiIn;		// handle to the opened midi in device
	WORD		wDeviceID;		// the device ID corresponding to this device
	void FAR*	lpSync;			// pointer to sync device for midi in
	DWORD		dwFlags;		// internal flags used to manage midi in
	MidiEvent	sysexEvent;		// expanded sysex event for MidiIn
	HWND		hMWnd;			// handle to the window that is to process messages
	WORD		nSysexBufSize;	// size, in bytes, of each sysex buffer
	DWORD	  	pMidiInDataIn;	// pointer to location to receive next message
	DWORD	  	pMidiInDataOut;	// pointer to location to retrieve this message
	WORD		nMidiInSize;	// size of the midi in buffer
	LPMIDIEVENT lpMidiInDataHead; // address of start of queue
	DWORD		lpSysexData;	// offset pointer to sysex data in current buffer
	DWORD		dwLastEventTicks; // time of the last event to calculate delta times
	LPDWORD*	lpHeaderList;	// start of list of midiin headers in round-robin
	WORD		nSysexBuffs;	// number of sysex buffers allocated
	WORD		nHeaderIn;		// index to next header to insert into the list
	WORD		nHeaderOut;		// index to this header to retreive data from

	// *** V1.55 ***
	DWORD		dwFilters;		// midi input filter settings

	// *** V1.57 ***
	WORD		nHeaderSpan;	// number of buffers between nHeaderIn and nHeaderOut
} MidiInStruct;

typedef MidiInStruct FAR* LPMIDIIN;

//-----------------------------------------------------------------------------
//	MIDI Out Definitions
//-----------------------------------------------------------------------------
typedef struct {
	HWND		hWnd;			// handle to the client window that receives MOM_... messages
	HMIDIOUT	hMidiOut;		// handle to the opened midi out device
	void FAR*	lpSync;			// pointer to sync device for midi out
	WORD		wDeviceID;		// the device ID corresponding to this device
	DWORD		dwFlags;		// flags used to manage midi out
	HWND		hMWnd;			// handle to the window that is to receive midi out process msgs
	WORD		nSysexBufSize;	// size, in bytes, of each sysex buffer
	DWORD		pMidiOutDataIn;	// pointer to location to receive next message
	DWORD		pMidiOutDataOut; // pointer to location to retrieve this message
	LPMIDIEVENT lpMidiOutDataHead;// address of start of queue
	WORD		nMidiOutSize;	// size, in events, of the out buffer
	WORD		wSpan;			// distance in events between in and out buffer pointers
	WORD		wNotes[128];	// tracking array for note on/offs
	LPDWORD*	lpHeaderList;	// start of list of midiout headers in round-robin
	WORD		nThisHeader;	// index of next header to use for sysex output
	WORD		nAvailableBuffs; // count of queue-able sysex buffers left
	WORD		nSysexBuffsAllowed; // max number of active sysex buffers
	DWORD		dwLastEventTicks; // time of the last event to calculate delta times

	// *** V1.55 ***
	DWORD		dwFilters;		// midi output filter settings
} MidiOutStruct;

typedef MidiOutStruct FAR* LPMIDIOUT;

//-----------------------------------------------------------------------------
//	Sync Timer definitions
//-----------------------------------------------------------------------------
typedef struct {
	HWND		hWnd;			// handle to the client window that will receive messages
	WORD		wSyncMode;		// sync mode, S_INT, S_CLOCK...
	WORD		wTimerPeriod;	// period of timer in ms
	LPMIDIIN	lpSyncIn;		// input device for sync--tempo events go to this device's queue
	WORD		wFlags;			// flags used to manage sync
	WORD		wTimerID;		// ID of the timer, NULL if not in use
	DWORD		dwTicks;		// current tick value for sync
	WORD		nTicksSinceBeat; // number of ticks since last beat
	DWORD		dwTempo;		// current tempo in uS/midi beat
	WORD		wResolution;	// sync resolution in ticks/midi beat
	DWORD		dwTRtime;		// set to resolution*ticktime[syncMode]
	DWORD		dwFticks;		// remaining fraction of a tick in (resolution*time)
	LPMIDIOUT FAR*	lpMidiOutList;	// pointer to head of list of midi outs that
								// are serviced by this sync device
	WORD		nTicksPerClock;	// number of ticks per midi beat for clocks
	WORD		nTicksSinceClock; // number of ticks since last clock
	WORD		wTempoTicks;	// count of elaspsed ticks for midi sync tempo calc
	DWORD		dwLastTicks;	// tick count at last midi clock for midi sync
	WORD		nSysexBuffsActive; // count of active sysex buffers
    DWORD		msPosition;		// current position in sequence, in milliseconds
} SyncStruct;

typedef SyncStruct FAR* LPSYNC;

//------------------------------------------------------------------------
// Standard Midi File Structures
//------------------------------------------------------------------------
#define IN_SYSEX 0x0001			// true if currently reading a sysex

typedef struct {
	DWORD		dwLength;		// length of track in bytes
	BYTE		bStatus;		// running status for this track
	LPSTR		lpReadBuf;		// buffer for data to read
	DWORD		dwRBsize;		// size of the read buffer
	DWORD		dwBuffOfs;		// current offset into buffer
	DWORD		dwFileOfs;		// file offset for start of buffer
	DWORD		dwBytesRemaining; // number of bytes in buffer
	DWORD		dwSysexLen;		// length of sysex block
	BYTE		bMetaStatus;	// running status for ReadMeta...
	LPDWORD		lpMetaOfs;		// pointer to array of offsets
								// to meta events for ReadMeta...
	BOOL		fEndOfTrack;	// true if reading has reached EOT
	WORD		wFlags;			// flags used by this track
	DWORD		dwMetaDeltaTime; // accumulated delta time for skipped meta events
	LPDWORD		lpMetaTime;		// pointer to array of elapsed times
								// for each meta event for ReadMeta...
} TrackStruct;
typedef TrackStruct* LPTRACK;

typedef struct {
	char		mode;			// mode for read 'r' or write 'w'
	HANDLE		hsmf;			// file handle for smf
	short		wFormat;		// smf file format
	short		wTracks;		// number of tracks in file
	short		resolution;		// timing resolution in tpb
	LPTRACK		lpTrack;		// pointer to array of track structures
	short		wCurTrack;		// current working track number
	LPSTR		lpMetaBuff;		// buffer for meta strings
	DWORD		dwCurFileOfs;	// actual offset into file
	DWORD		dwChunkStart;	// start position of chunk for WriteSMF
	DWORD		dwChunkLen;		// length of chunk for WriteSMF
	BYTE		bStatus;		// current status for WriteSMF
	DWORD		dwSxLen;		// length of sysex for WriteSMF
	DWORD		dwSxBuffSize;	// size of buffer for sysex write
	LPSTR		lpSxBuff;		// pointer to sysex write buffer
} SMFStruct;

typedef SMFStruct* LPSMF;
#pragma pack()

//-----------------------------------------------------------------------------
//	Internal Function Prototypes
//-----------------------------------------------------------------------------
PREFIX void CALLBACK WINAPI EXPORT MidiInCallback(HMIDIIN hMI, UINT wMsg, DWORD dwInstance, DWORD dwParam1, DWORD dwParam2);
PREFIX LRESULT CALLBACK WINAPI EXPORT MidiInProc(HWND hWnd, UINT iMessage, WPARAM wParam, LPARAM lpMidiIn);
PREFIX LRESULT CALLBACK WINAPI EXPORT MidiOutProc(HWND hWnd, UINT iMessage, WPARAM wParam, LPARAM lParam);
PREFIX void CALLBACK WINAPI EXPORT MidiOutCallback(HMIDIIN hMI, UINT wMsg, DWORD dwInstance, DWORD dwParam1, DWORD dwParam2);
PREFIX LRESULT CALLBACK WINAPI EXPORT MidiOutProc(HWND hWnd, UINT iMessage, WPARAM wParam, LPARAM lParam);
PREFIX void CALLBACK WINAPI EXPORT syncTimer(UINT wTimerID, UINT wMsg, DWORD dwUser, DWORD dw1, DWORD dw2);
void PostUserMessage(HWND hWnd, LPMIDIEVENT lpEvent);

//-----------------------------------------------------------------------------
//	MxMidi16 16-bit API
//-----------------------------------------------------------------------------
#ifndef WIN32
PREFIX void WINAPI EXPORT FreeGlobalMem16(void FAR* gMem);
#endif

PREFIX WORD WINAPI EXPORT GetMaxMidiVersion16(void);

PREFIX BOOL WINAPI EXPORT GetMidiOutDescription16(WORD wDeviceID, LPSTR lpzDesc);
PREFIX HMOUT WINAPI EXPORT OpenMidiOut16(HWND hWnd, WORD wDeviceID, HSYNC hSync, DWORD dwFlags);
PREFIX WORD WINAPI EXPORT ResetMidiOut16(HMOUT hMidiOut);
PREFIX void WINAPI EXPORT FlushMidiOut16(HMOUT hMidiOut);
PREFIX WORD WINAPI EXPORT CloseMidiOut16(HMOUT hMidiOut);
PREFIX WORD WINAPI EXPORT PutMidiOut16(HMOUT hMidiOut, LPMIDIEVENT lpMidiEvent);

// *** V1.55 ***
PREFIX DWORD WINAPI EXPORT GetMidiOutFilters16(HMOUT hMidiOut);
PREFIX void WINAPI EXPORT SetMidiOutFilters16(HMOUT hMidiOut, DWORD dwFilters);

PREFIX BOOL WINAPI EXPORT GetMidiInDescription16(WORD wDeviceID, LPSTR lpzDesc);
PREFIX HMIN WINAPI EXPORT OpenMidiIn16(HWND hWnd, WORD wDeviceID, HSYNC hSync, DWORD dwFlags);
PREFIX WORD WINAPI EXPORT StartMidiIn16(HMIN lpMidiIn);
PREFIX WORD WINAPI EXPORT StopMidiIn16(HMIN lpMidiIn);
PREFIX WORD WINAPI EXPORT CloseMidiIn16(HMIN lpMidiIn);
PREFIX LPMIDIEVENT WINAPI EXPORT GetMidiIn16(HMIN lpMidiIn);

// *** V1.55 ***
PREFIX DWORD WINAPI EXPORT GetMidiInFilters16(HMIN hMidiIn);
PREFIX void WINAPI EXPORT SetMidiInFilters16(HMIN hMidiIn, DWORD dwFilters);

PREFIX HSYNC WINAPI EXPORT OpenSync16(HSYNC hSync, HWND hWnd, WORD mode, WORD timerPeriod);
PREFIX WORD WINAPI EXPORT CloseSync16(HSYNC hSync);
PREFIX void WINAPI EXPORT StopSync16(HSYNC hSync);
PREFIX void WINAPI EXPORT StartSync16(HSYNC hSync);
PREFIX void WINAPI EXPORT PauseSync16(HSYNC hSync, BOOL reset);
PREFIX void WINAPI EXPORT ReStartSync16(HSYNC hSync);
PREFIX WORD WINAPI EXPORT SetTempo16(HSYNC hSync, DWORD uSPerBeat);
PREFIX void WINAPI EXPORT SetResolution16(HSYNC hSync, WORD resolution);
PREFIX DWORD WINAPI EXPORT GetTempo16(HSYNC hSync);
PREFIX WORD WINAPI EXPORT GetResolution16(HSYNC hSync);
PREFIX DWORD WINAPI EXPORT GetPosition16(HSYNC hSync, WORD units);

#ifdef WIN32
PREFIX WORD WINAPI EXPORT GetMaxMidiVersionEx(void);

PREFIX BOOL WINAPI EXPORT GetMidiOutDescriptionEx(WORD wDeviceID, LPSTR lpzDesc);
PREFIX HMOUT WINAPI EXPORT OpenMidiOutEx(HWND hWnd, WORD wDeviceID, HSYNC hSync, DWORD dwFlags);
PREFIX WORD WINAPI EXPORT ResetMidiOutEx(HMOUT hMidiOut);
PREFIX void WINAPI EXPORT FlushMidiOutEx(HMOUT hMidiOut);
PREFIX WORD WINAPI EXPORT CloseMidiOutEx(HMOUT hMidiOut);
PREFIX WORD WINAPI EXPORT PutMidiOutEx(HMOUT hMidiOut, LPMIDIEVENT lpMidiEvent);

// *** V1.55 ***
PREFIX DWORD WINAPI EXPORT GetMidiOutFiltersEx(HMOUT hMidiOut);
PREFIX void WINAPI EXPORT SetMidiOutFiltersEx(HMOUT hMidiOut, DWORD dwFilters);

PREFIX BOOL WINAPI EXPORT GetMidiInDescriptionEx(WORD wDeviceID, LPSTR lpzDesc);
PREFIX HMIN WINAPI EXPORT OpenMidiInEx(HWND hWnd, WORD wDeviceID, HSYNC hSync, DWORD dwFlags);
PREFIX WORD WINAPI EXPORT StartMidiInEx(HMIN lpMidiIn);
PREFIX WORD WINAPI EXPORT StopMidiInEx(HMIN lpMidiIn);
PREFIX WORD WINAPI EXPORT CloseMidiInEx(HMIN lpMidiIn);
PREFIX LPMIDIEVENT WINAPI EXPORT GetMidiInEx(HMIN lpMidiIn);

// *** V1.55 ***
PREFIX DWORD WINAPI EXPORT GetMidiInFiltersEx(HMIN hMidiIn);
PREFIX void WINAPI EXPORT SetMidiInFiltersEx(HMIN hMidiIn, DWORD dwFilters);

PREFIX HSYNC WINAPI EXPORT OpenSyncEx(HSYNC hSync, HWND hWnd, WORD mode, WORD timerPeriod);
PREFIX WORD WINAPI EXPORT CloseSyncEx(HSYNC hSync);
PREFIX void WINAPI EXPORT StopSyncEx(HSYNC hSync);
PREFIX void WINAPI EXPORT StartSyncEx(HSYNC hSync);
PREFIX void WINAPI EXPORT PauseSyncEx(HSYNC hSync, BOOL reset);
PREFIX void WINAPI EXPORT ReStartSyncEx(HSYNC hSync);
PREFIX WORD WINAPI EXPORT SetTempoEx(HSYNC hSync, DWORD uSPerBeat);
PREFIX void WINAPI EXPORT SetResolutionEx(HSYNC hSync, WORD resolution);
PREFIX DWORD WINAPI EXPORT GetTempoEx(HSYNC hSync);
PREFIX WORD WINAPI EXPORT GetResolutionEx(HSYNC hSync);
PREFIX DWORD WINAPI EXPORT GetPositionEx(HSYNC hSync, WORD units);
#endif

// pointers to functions -- either in MxMidi32 for NT, or in MxMidi95 for Win95
typedef WORD (CALLBACK* PGetMaxMidiVersion32)(void);

typedef BOOL (CALLBACK* PGetMidiOutDescription32)(WORD wDeviceID, LPSTR lpzDesc);
typedef HMOUT (CALLBACK* POpenMidiOut32)(HWND hWnd, WORD wDeviceID, HSYNC hSync, DWORD dwFlags);
typedef WORD (CALLBACK* PResetMidiOut32)(HMOUT hMidiOut);
typedef void (CALLBACK* PFlushMidiOut32)(HMOUT hMidiOut);
typedef WORD (CALLBACK* PCloseMidiOut32)(HMOUT hMidiOut);
typedef WORD (CALLBACK* PPutMidiOut32)(HMOUT hMidiOut, LPMIDIEVENT lpMidiEvent);

// *** V1.55 ***
typedef DWORD (CALLBACK* PGetMidiOutFilters32)(HMOUT hMidiOut);
typedef void (CALLBACK* PSetMidiOutFilters32)(HMOUT hMidiOut, DWORD dwFilters);

typedef BOOL (CALLBACK* PGetMidiInDescription32)(WORD wDeviceID, LPSTR lpzDesc);
typedef HMIN (CALLBACK* POpenMidiIn32)(HWND hWnd, WORD wDeviceID, HSYNC hSync, DWORD dwFlags);
typedef WORD (CALLBACK* PStartMidiIn32)(HMIN lpMidiIn);
typedef WORD (CALLBACK* PStopMidiIn32)(HMIN lpMidiIn);
typedef WORD (CALLBACK* PCloseMidiIn32)(HMIN lpMidiIn);
typedef LPMIDIEVENT (CALLBACK* PGetMidiIn32)(HMIN lpMidiIn);

// *** V1.55 ***
typedef DWORD (CALLBACK* PGetMidiInFilters32)(HMIN hMidiIn);
typedef void (CALLBACK* PSetMidiInFilters32)(HMIN hMidiIn, DWORD dwFilters);

typedef HSYNC (CALLBACK* POpenSync32)(HSYNC hSync, HWND hWnd, WORD mode, WORD timerPeriod);
typedef WORD (CALLBACK* PCloseSync32)(HSYNC hSync);
typedef void (CALLBACK* PStopSync32)(HSYNC hSync);
typedef void (CALLBACK* PStartSync32)(HSYNC hSync);
typedef void (CALLBACK* PPauseSync32)(HSYNC hSync, BOOL reset);
typedef void (CALLBACK* PReStartSync32)(HSYNC hSync);
typedef WORD (CALLBACK* PSetTempo32)(HSYNC hSync, DWORD uSPerBeat);
typedef void (CALLBACK* PSetResolution32)(HSYNC hSync, WORD resolution);
typedef DWORD (CALLBACK* PGetTempo32)(HSYNC hSync);
typedef WORD (CALLBACK* PGetResolution32)(HSYNC hSync);
typedef DWORD (CALLBACK* PGetPosition32)(HSYNC hSync, WORD units);

#ifdef __cplusplus
}                       // End of extern "C" {
#endif

