#include "s3e.h"
#include <memory.h>

void onInit() {
}

void onShutDown() {
}

bool onUpdate() {
	return true;
}

void onRender() {
	// Get pointer to the screen surface
	// (pixel depth is 2 bytes by default)
	uint16* screen = (uint16*)s3eSurfacePtr();
	int height = s3eSurfaceGetInt(S3E_SURFACE_HEIGHT);
	int width = s3eSurfaceGetInt(S3E_SURFACE_WIDTH);
	int pitch = s3eSurfaceGetInt(S3E_SURFACE_PITCH);
	
	// Clear screen to white
	for (int i=0; i < height; i++)
	{
		memset((char*)screen + pitch * i, 255, (width * 2));
	}
	// Print Hello World
	s3eDebugPrint(10, 20, "`x000000Hello World", 0);
}

//--------------------------------------------------------------------------
// Main global function
//--------------------------------------------------------------------------
S3E_MAIN_DECL void IwMain()
{
#ifdef EXAMPLE_DEBUG_ONLY
	// Test for Debug only examples
#endif
	onInit();
	while (1)
	{
		s3eDeviceYield(0);
		s3eKeyboardUpdate();
		bool result = onUpdate();
		if (
			(result == false) ||
			(s3eKeyboardGetState(s3eKeyEsc) & S3E_KEY_STATE_DOWN)
			||
			(s3eKeyboardGetState(s3eKeyLSK) & S3E_KEY_STATE_DOWN)
			||
			(s3eDeviceCheckQuitRequest())
			) {
			break;
		}
		onRender();
		s3eSurfaceShow();
	}
	onShutDown();
}