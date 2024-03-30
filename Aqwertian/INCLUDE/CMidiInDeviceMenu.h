//---------------------------------------------------------------------------
//	CMidiInDeviceMenu Class Definition
//
//	(C) Copyright, Paul A. Messick, 1996
//---------------------------------------------------------------------------
class CMidiInDeviceMenu
{
protected:
	HMENU	hPopupMenu;
	int		nMaxDevices;
	UINT	idm_base;
	CMaxMidiIn* MidiIn;

public:
	CMidiInDeviceMenu() { nMaxDevices = 0; MidiIn = NULL; };
	CMidiInDeviceMenu(HMENU hMenu, UINT position, LPSTR name, UINT baseMsg);
	~CMidiInDeviceMenu() { };

	void Create(HMENU hMenu, UINT position, LPSTR name, UINT baseMsg);
	void Attach(CMaxMidiIn* Device) { MidiIn = Device; };

	BOOL GetDeviceName(WORD dwDevice, LPSTR name);
	int GetDeviceCount(void) { return nMaxDevices; };
	HMENU GetMenu(void) { return hPopupMenu; };

	virtual BOOL SelectDevice(UINT id);
};

