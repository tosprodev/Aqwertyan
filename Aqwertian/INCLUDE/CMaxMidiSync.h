//---------------------------------------------------------------------------
//	CMaxMidiSync Class Definition
//
//	(C) Copyright, Paul A. Messick, 1996
//---------------------------------------------------------------------------
class CMaxMidiSync : public CWnd
{
// Class-specific data
protected:
	HSYNC		hDevice;		// handle to the Sync device
	BOOL		fIsOpen;		// true if device is open
	WORD		CurrentMode;	// current sync mode
	WORD		CurrentPeriod;	// current timer period
	HWND		hParentWnd;		// hWnd for sync messages
	BOOL		fRunning;		// true is sync is active

public:
// Constructors/Destructor
	CMaxMidiSync();				// default constructor
	CMaxMidiSync(HWND hParentWnd);
	CMaxMidiSync(HWND hParentWnd, WORD mode = S_INT, WORD timerPeriod = 10);
	~CMaxMidiSync();			// destructor

// Implementation
	BOOL CreateWnd(void);		// creates the hidden window
	void Attach(HWND hParentWnd); // attaches the parent window

	BOOL IsOpen(void);			// returns true if device is open
	BOOL IsRunning(void) { return fRunning; };
	HSYNC GetHSync(void) { return hDevice; };

	BOOL Open(WORD mode = S_INT, WORD timerPeriod = 10);
	void Close(void);			// close the device without destroying class object

	BOOL Mode(WORD mode);		// set new sync mode
	WORD Mode(void) { return CurrentMode; };
	BOOL Period(WORD period);	// set new timer period
	WORD Period(void) { return CurrentPeriod; };

	void Start(void);			// start sync
	void ReStart(void);			// restart sync after pause
	void Stop(void);			// stop sync
	void Pause(BOOL reset = FALSE); // pause sync, send note offs if reset = true

	BOOL Tempo(DWORD tempo);	// set the tempo in uS/beat
	DWORD Tempo(void);			// get the current tempo in uS/beat
	DWORD Convert(double tempo); // convert bpm to uS/beat
	double Convert(DWORD tempo); // convert uS/beat to bpm

	WORD Resolution(void);		// get the current resolution in tpb
	void Resolution(WORD res);	// set the current resolution in tpb

	virtual void ProcessMidiBeat(void) { };
	virtual void ProcessSyncDone(void) { };

// Generated message map functions
protected:
	//{{AFX_MSG(CMaxMidiSync)
	afx_msg LPARAM OnMidiBeat(WPARAM wParam, LPARAM lParam);
	afx_msg LPARAM OnSyncDone(WPARAM wParam, LPARAM lParam);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};
