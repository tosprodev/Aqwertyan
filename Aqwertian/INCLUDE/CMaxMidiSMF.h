//---------------------------------------------------------------------------
//	CMaxMidiSMF Class Definition
//
//	(C) Copyright, Paul A. Messick, 1996
//---------------------------------------------------------------------------
class CMaxMidiSMF
{
// Class-specific data
protected:
	HMIN	hSMF;				// handle to the SMF
	BOOL	fIsOpen;			// true if device is open
	char	Mode;				// 'r' for read, 'w' for write
	int		Format;				// SMF format type
	int		nTracksInSMF;		// number of tracks in SMF
	int		nTracksAttached;	// number of tracks attached to object
	CMaxMidiTrack** pTrackList;	// array of track object pointers

public:
// Constructors/Destructor
	CMaxMidiSMF();				// default constructor
	CMaxMidiSMF(LPCTSTR filename, const char Mode);
	CMaxMidiSMF(LPSTR filename, const char Mode);
	~CMaxMidiSMF();				// destructor

// Implementation
	void Attach(CMaxMidiTrack* pTrack);
	void Attach(CMaxMidiTrack* pTrack, int position);
	BOOL Detach(CMaxMidiTrack* pTrack);

	BOOL IsOpen(void) { return fIsOpen; };	// returns true if device is open
	int NumTracks(void) { return nTracksInSMF; };
	int GetFormat(void) { return Format; };
	char GetMode(void) { return Mode; };
	
	BOOL Open(LPCTSTR filename, const char Mode, int Format = 1);
	BOOL Open(LPSTR filename, const char Mode, int Format = 1);
	void Close(void);			// close the device without destroying class object

	WORD Resolution(void) { return GetSMFResolution(hSMF); };
	WORD Resolution(WORD res) { return SetSMFResolution(hSMF, res); };
	virtual BOOL Read(CMaxMidiTrack* pTrack);
	virtual BOOL Write(CMaxMidiTrack* pTrack);
	DWORD ReadMeta(CMaxMidiTrack* pTrack, BYTE type, LPSTR* Value, DWORD* cbSize);
	BOOL WriteMeta(CMaxMidiTrack* pTrack, BYTE type, LPSTR Value, DWORD time);
	BOOL Rewind(void) { return RewindSMF(hSMF) == 0; };

	BOOL Load(void);
	BOOL Save(void);
};

#define READ 'r'
#define WRITE 'w'
