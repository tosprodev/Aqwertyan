//---------------------------------------------------------------------------
//	CMaxMidiOut Class Definition
//
//	(C) Copyright, Paul A. Messick, 1996
//---------------------------------------------------------------------------

#ifdef _TRACK
//---------------------------------------------------------------------------
//	TrackMerge structure
//---------------------------------------------------------------------------
typedef struct {
	CMaxMidiTrack*	pTrack;		// track object
	LPMIDIEVENT		pAbsBuf;	// track buffer in absolute time
	DWORD			bufSize;	// number of events in abs buffer
	DWORD			thisEvent;	// index in AbsBuf of next event to read
	DWORD			lastEvent;	// index of last event output from this track
	BOOL			fInSysex;	// true if currently in sysex in this track
} TrackMerge;
#endif

class CMaxMidiOut : public CWnd
{
// Class-specific data
protected:
	HMOUT		hDevice;		// handle to the MidiOut device
	DWORD		dwFlags;		// current flags, in case we reopen
	WORD		wDeviceID;		// device ID of attached device

	BOOL		fIsOpen;		// true if device is open
	char		Description[MAXPNAMELEN]; // description string
	HWND		hParentWnd;		// parent window handle
	DWORD		LastAbs;		// last absolute timestamp used during track merge

#ifdef _SYNC
	CMaxMidiSync* pSync;		// the sync device object
#endif

#ifdef _TRACK
	TrackMerge* pTrackList;		// list of attached track merge structs
	int			nTracks;		// number of attached tracks
	LPMIDIEVENT	lpMerge;		// pointer to the merged output data
	DWORD		numEvents;		// number of events in the merged buffer
	DWORD		outPtr;			// index to retrieve next event from merge buffer
#endif

public:
	CMaxMidiOut();				// default constructor
	CMaxMidiOut(HWND hParentWnd, WORD wDeviceID = 0);
	~CMaxMidiOut();				// destructor

// sync-dependent functions
#ifdef _SYNC
	CMaxMidiOut(HWND hParentWnd, WORD wDeviceID, CMaxMidiSync* pSync = 0, DWORD dwFlags = MIDIOUT_DEFAULT);
	void Attach(CMaxMidiSync* pSync);	// attaches the sync device
	void Detach(CMaxMidiSync* pSync);	// detaches the sync device
	CMaxMidiSync* GetSync(void) { return pSync; };
#endif

// track-dependent functions
#ifdef _TRACK
	void Attach(CMaxMidiTrack* pTrack);	// attaches the track object
	BOOL Detach(CMaxMidiTrack* pTrack);	// detaches the track object
	LPMIDIEVENT MergeTracks(void);
	void MergeOut(void);
	void StartOut(void);
#endif

// Implementation
	WORD GetIDFromName(LPSTR lpszDesc); // find corresponding ID given string name

	BOOL CreateWnd(void);		// creates the hidden window
	void Attach(HWND hParentWnd); // attaches the parent window

	BOOL IsOpen(void);			// returns true if device is open
	LPSTR GetDescription(void); // returns pointer to desc string
	int GetNumDevices(void);	// returns number of output devices available

	BOOL Open(WORD wDeviceID, DWORD dwFlags = MIDIOUT_DEFAULT);
	void Close(void);			// close the device without destroying class object

	BOOL Put(LPMIDIEVENT lpEvent); // output an event
	void Reset(void);			// reset the output device
	void Flush(void);			// flush the output queue

	// *** V1.55 DLL ***
	DWORD GetFilters(void) { return GetMidiOutFilters(hDevice); };
	void SetFilters(DWORD dwFilters) { SetMidiOutFilters(hDevice, dwFilters); };

	virtual void ProcessOutBufferReady(void) { };

// Generated message map functions
protected:
	//{{AFX_MSG(CMaxMidiOut)
	afx_msg LPARAM OnOutBufferReady(WPARAM wParam, LPARAM lParam);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

#define MERGE_BUFFER_SIZE 512	// should be the size of the output device buffer
