//---------------------------------------------------------------------------
//	CMaxMidiTrack Class Definition
//
//	(C) Copyright, Paul A. Messick, 1996
//---------------------------------------------------------------------------
#define DEFAULT_BUFFER_SIZE 8192
#define BUFFER_GROW_SIZE DEFAULT_BUFFER_SIZE

class CMaxMidiTrack
{
// Class-specific data
protected:
#ifdef _SMF
	CMaxMidiSMF* pSMF;				// SMF connected to this track
#endif
#ifdef _MIDIOUT
	CMaxMidiOut* pMidiOut;			// MidiOut device connected to this track
#endif
#ifdef _MIDIIN
	CMaxMidiIn*  pMidiIn;			// MidiIn device connected to this track
#endif

	LPMIDIEVENT lpBuffer;			// buffer for events
	DWORD		dwBufSize;			// size of buffer, in events
	DWORD		inPtr;				// buffer write index
	DWORD		outPtr;				// buffer read index
	BOOL		fRecord;			// true if recording into this track
	BOOL		fMute;				// true if playback is muted
	LPSTR		lpName;				// track name string

public:
// Constructors/Destructor
	CMaxMidiTrack();				// default constructor
	~CMaxMidiTrack();				// destructor

// Implementation
// smf-dependent functions
#ifdef _SMF
	void Attach(CMaxMidiSMF* pSMF);
	void Detach(CMaxMidiSMF* pSMF);
	CMaxMidiSMF* GetSMF(void) { return pSMF; };
#endif

// midi out-dependent functions
#ifdef _MIDIOUT
	void Attach(CMaxMidiOut* pMidiOut);
	void Detach(CMaxMidiOut* pMidiOut);
	CMaxMidiOut* GetMidiOut(void) { return pMidiOut; };
#endif

// midi in-dependent functions
#ifdef _MIDIIN
	void Attach(CMaxMidiIn* pMidiIn);
	void Detach(CMaxMidiIn* pMidiIn);
	CMaxMidiIn* GetMidiIn(void) { return pMidiIn; };
#endif

	void Detach(void);
		
	BOOL IsEmpty(void) { return (inPtr - outPtr) == 0; };
	BOOL IsRecording(void) { return fRecord; };
	void IsRecording(BOOL record) { fRecord = record; };

	void Mute(BOOL mute) { fMute = mute; };
	BOOL Mute(void) { return fMute; };

	LPSTR GetName(void);
	void SetName(LPSTR name);

	DWORD GetNumEvents(void) { return (DWORD)(inPtr - outPtr); };
	void SetNumEvents(DWORD nEvents) { Flush(); inPtr = nEvents; };

	BOOL CreateBuffer(DWORD dwBufEvents = DEFAULT_BUFFER_SIZE);
	LPMIDIEVENT GetBuffer(void) { return lpBuffer; };
	void SetBuffer(LPMIDIEVENT lpNewBuf) { lpBuffer = lpNewBuf; };
	DWORD GetBufferSize(void) { return dwBufSize; };
	void SetBufferSize(DWORD dwBufEvents) { dwBufSize = dwBufEvents; };
	void FreeBuffer(void);

	LPMIDIEVENT GetEvent(DWORD eventNum);
	void SetEvent(LPMIDIEVENT lpEvent, DWORD eventNum);
	DWORD GetTime(DWORD eventNum);

	LPMIDIEVENT Read(void);
	void Write(LPMIDIEVENT lpEvent);
	void Flush(void) { inPtr = outPtr = 0; };
	void Rewind(void) { outPtr = 0; };

	BOOL Load(void);
	BOOL Save(void);

	LPMIDIEVENT GetAbsBuffer(DWORD startEvent, DWORD* numEvents);
	DWORD AbsNow(DWORD eventNum);
	void AbsToDelta(LPMIDIEVENT lpBuf, DWORD startEvent, DWORD numEvents);
	void DeltaToAbs(LPMIDIEVENT lpBuf, DWORD startEvent, DWORD numEvents);

	void InsertEvent(LPMIDIEVENT lpEvent, DWORD beforeEvent);
	void DeleteEvent(DWORD eventNum);
	void SlideTrack(DWORD eventNum, int delta);
};

