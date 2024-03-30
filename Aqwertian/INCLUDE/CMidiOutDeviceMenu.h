//---------------------------------------------------------------------------
//	CMidiOutDeviceMenu Class Definition
//
//	(C) Copyright, Paul A. Messick, 1996
//---------------------------------------------------------------------------
class CMidiOutDeviceMenu
{
protected:
	HMENU	hPopupMenu;
	int		nMaxDevices;
	WORD	MapperID;
	UINT	idm_base;
	CMaxMidiOut* MidiOut;

public:
	CMidiOutDeviceMenu() { nMaxDevices = 0; MidiOut = NULL; };
	CMidiOutDeviceMenu(HMENU hMenu, UINT position, LPSTR name, UINT baseMsg);
	~CMidiOutDeviceMenu() { };

	void Create(HMENU hMenu, UINT position, LPSTR name, UINT baseMsg);
	void Attach(CMaxMidiOut* Device) { MidiOut = Device; };

	int GetDeviceCount(void) { return nMaxDevices; };
	HMENU GetMenu(void) { return hPopupMenu; };
	BOOL GetDeviceName(WORD dwDevice, LPSTR name);

	virtual BOOL SelectDevice(UINT id);
};

