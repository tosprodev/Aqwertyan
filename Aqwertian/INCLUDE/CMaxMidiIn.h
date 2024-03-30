//---------------------------------------------------------------------------
//	CMaxMidiIn Class Definition
//
//	(C) Copyright, Paul A. Messick, 1996
//---------------------------------------------------------------------------
class CMaxMidiIn : public CWnd
{
// Class-specific data
protected:
	HMIN		hDevice;		// handle to the MidiIn device
	DWORD		dwFlags;		// current flags for this device
	WORD		wDeviceID;		// device id, in case we need to reopen

	BOOL		fIsOpen;		// true if device is open
	char		Description[MAXPNAMELEN]; // description string
	HWND		hParentWnd;		// parent window handle
#ifdef _SYNC
	CMaxMidiSync* pSync; 		// the sync device object
#endif
#ifdef _TRACK
	CMaxMidiTrack* pTrack;		// track object associated with this input (only one)
#endif
	BOOL		fIsStarted;		// true if input started

public:
// Constructors/Destructor
	CMaxMidiIn();				// default constructor
	CMaxMidiIn(HWND hParentWnd, WORD wDeviceID = 0);
	~CMaxMidiIn();				// destructor

// sync-dependent functions
#ifdef _SYNC
	CMaxMidiIn(HWND hParentWnd, WORD wDeviceID, CMaxMidiSync* pSync = NULL, DWORD dwFlags = MIDIIN_DEFAULT);
	void Attach(CMaxMidiSync* pSync);	// attaches the sync device
	void Detach(CMaxMidiSync* pSync);	// detaches the sync device
	CMaxMidiSync* GetSync(void) { return pSync; };
#endif

// track-dependent functions
#ifdef _TRACK
	void Attach(CMaxMidiTrack* pTrack); // attaches the track object
	void Detach(CMaxMidiTrack* pTrack);	// detaches the track object
#endif

// Implementation
	WORD GetIDFromName(LPSTR lpszDesc); // find corresponding ID given string name
	
	BOOL CreateWnd(void);				// creates the hidden window
	void Attach(HWND hParentWnd);		// attaches the parent window

	BOOL IsOpen(void);			// returns true if device is open
	LPSTR GetDescription(void); // returns pointer to desc string
	int GetNumDevices(void);	// returns number of input devices available

	BOOL Open(WORD wDeviceID, DWORD dwFlags = MIDIIN_DEFAULT);
	void Close(void);			// close the device without destroying class object

	void Start(void);			// start midi in
	void Stop(void);			// stop midi in
	void Reset(void);			// reset the timestamp to zero, if started
	LPMIDIEVENT Get(void);		// get received event, if any

	// *** V1.55 DLL ***
	DWORD GetFilters(void) { return GetMidiInFilters(hDevice); };
	void SetFilters(DWORD dwFilters) { SetMidiInFilters(hDevice, dwFilters); };

	virtual BOOL ProcessMidiData(LPMIDIEVENT lpEvent) { return TRUE; };

// Generated message map functions
protected:
	//{{AFX_MSG(CMaxMidiIn)
	afx_msg LPARAM OnMidiData(WPARAM wParam, LPARAM lParam);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

