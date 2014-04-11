/*
 * This file is part of the Airplay SDK Code Samples.
 *
 * Copyright (C) 2001-2010 Ideaworks3D Ltd.
 * All Rights Reserved.
 *
 * This source code is intended only as a supplement to Ideaworks Labs
 * Development Tools and/or on-line documentation.
 *
 * THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
 * KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
 * PARTICULAR PURPOSE.
 */

//-----------------------------------------------------------------------------
// ExampleIwUICalculator
//-----------------------------------------------------------------------------

/**
 * @page ExampleIwUICalculator IwUI Calculator Example
 * The following example demonstrates a simple calculator
 * 
 * The main classes used to achieve this are:
 *
 * <ul> 
 * <li> CIwUIView
 * 
 * <li> CIwUIController
 * 
 * <li> CIwUIElement
 * 
 * <li> CIwUIButton
 * 
 * <li> CIwUILabel
 * 
 * <li> CIwUIImage
 * 
 * </ul>
 * 
 * The main functions used to achieve this are:
 * 
 * <ul> 
 * <li> IwUIInit()
 * 
 * <li> IwUITerminate();
 *
 * </ul>
 *
 * This example demonstrates a simple calculator with all the basic functionality.
 * 
 * The UI file consists of label to show the solution, and a grid of buttons that provide
 * the calculator with functionality. This UI file was constructed by using the ASUI Editor
 * tool, and a tutorial for re-creating it is available.
 *
 * Each button has a click handler that performs the appropriate calculator function. The result
 * is displayed in the label. 
 *
 * The following graphic illustrates the example output.
 *
 * @image html IwUICalculatorImage.png
 *
 * @include IwUICalculator.cpp
 * 
 */
//
// Library includes
#include "IwGx.h"
#include "IwGxFont.h"
#include "IwUI.h"
#include "IwUIAnimation.h"
#include "IwUIController.h"
#include "IwUIButton.h"
#include "IwUICheckbox.h"
#include "IwUIElement.h"
#include "IwUIEvent.h"
#include "IwUILabel.h"
#include "IwUISlider.h"
#include "IwUIView.h"
#include "IwUIProgressBar.h"
#include "IwUIPropertySet.h"
#include "s3eKeyboard.h"
#include "IwUISoftKeyboard.h"
#include "IwUITextInput.h"

extern bool g_IwTextureAssertPowerOf2;
bool g_Quit;
bool g_AC;
CIwUILabel* pLabel;
CIwUIButton* pButton_C;

#define DEFAULTSTYLE

#ifdef DEFAULTSTYLE
// Load the default Stylesheet
static const char* s_Stylesheets[] = 
{
	"Small",			// Small Size
	"Medium",			// Medium Size
	"Large",			// Large Size
};
#else
// Load the dark Stylesheet
static const char* s_Stylesheets[] = 
{
	"SmallDark",		// Small Size
	"MediumDark",		// Medium Size
	"LargeDark",		// Large Size
};
#endif

//Calculator Modes
enum {
	CALC_MODE_NONE,
	CALC_MODE_PLUS,
	CALC_MODE_MINUS,
	CALC_MODE_TIMES,
	CALC_MODE_DIVIDE,
};

char	CalcText[100];		//Holds the Calculator Text
int16	CalcMode	= CALC_MODE_NONE;
double	Memory		= 0;	//Holds Calculator Memory Value
double	LastValue	= 0;	//Holds the Value of the last operation
double	PastValue	= 0;	//Holds the Value of the operation for repeat
bool	b_Repeat	= false;//Repeat the last operation

#define BUTTON(x) void OnClickButton_##x(CIwUIElement*) { OnButtonPress(#x); }

void OnButtonPress(const char* button)
{
	//Handle button press 0-9
	if (!strcmp(CalcText, "0") || (button[0] == '0' && !strcmp(CalcText, "-0")))
		strcpy(CalcText, button);
	else if (strlen(CalcText) < 85)
		strcat(CalcText, button);
	
	pLabel->SetCaption(CalcText);
	pButton_C->SetCaption("C"); 
	g_AC = false;
}

void OnButtonEqual()
{
	//Load the value from the Calculator
	double NewValue = atof(CalcText);

	if (b_Repeat)
	{
		NewValue = PastValue;
		LastValue = atof(CalcText);
	}

	switch (CalcMode)
	{
		case CALC_MODE_PLUS:
			sprintf(CalcText, "%g", LastValue + NewValue);
			break;
		case CALC_MODE_MINUS:
			sprintf(CalcText, "%g", LastValue - NewValue);
			break;
		case CALC_MODE_TIMES:
			sprintf(CalcText, "%g", LastValue * NewValue);
			break;
		case CALC_MODE_DIVIDE:
			if (!atof(CalcText))
			{
				strcpy(CalcText, "0");
				pLabel->SetCaption("ERROR");
				return;
			}
			else
				sprintf(CalcText, "%g", LastValue / NewValue);
	}

	if (CalcMode)
	{
		pLabel->SetCaption(CalcText);
		if (!b_Repeat)
		{
			PastValue = NewValue;
			b_Repeat = true;
		}
	}
}

class CController : public CIwUIController
{
public:
	CController()
	{
		IW_UI_CREATE_VIEW_SLOT1(this, "CController", CController, OnClickButton_0, CIwUIElement*)
		IW_UI_CREATE_VIEW_SLOT1(this, "CController", CController, OnClickButton_1, CIwUIElement*)
		IW_UI_CREATE_VIEW_SLOT1(this, "CController", CController, OnClickButton_2, CIwUIElement*)
		IW_UI_CREATE_VIEW_SLOT1(this, "CController", CController, OnClickButton_3, CIwUIElement*)
		IW_UI_CREATE_VIEW_SLOT1(this, "CController", CController, OnClickButton_4, CIwUIElement*)
		IW_UI_CREATE_VIEW_SLOT1(this, "CController", CController, OnClickButton_5, CIwUIElement*)
		IW_UI_CREATE_VIEW_SLOT1(this, "CController", CController, OnClickButton_6, CIwUIElement*)
		IW_UI_CREATE_VIEW_SLOT1(this, "CController", CController, OnClickButton_7, CIwUIElement*)
		IW_UI_CREATE_VIEW_SLOT1(this, "CController", CController, OnClickButton_8, CIwUIElement*)
		IW_UI_CREATE_VIEW_SLOT1(this, "CController", CController, OnClickButton_9, CIwUIElement*)
		IW_UI_CREATE_VIEW_SLOT1(this, "CController", CController, OnClickButton_plus, CIwUIElement*)
		IW_UI_CREATE_VIEW_SLOT1(this, "CController", CController, OnClickButton_minus, CIwUIElement*)
		IW_UI_CREATE_VIEW_SLOT1(this, "CController", CController, OnClickButton_times, CIwUIElement*)
		IW_UI_CREATE_VIEW_SLOT1(this, "CController", CController, OnClickButton_divide, CIwUIElement*)
		IW_UI_CREATE_VIEW_SLOT1(this, "CController", CController, OnClickButton_equal, CIwUIElement*)
		IW_UI_CREATE_VIEW_SLOT1(this, "CController", CController, OnClickButton_plusminus, CIwUIElement*)
		IW_UI_CREATE_VIEW_SLOT1(this, "CController", CController, OnClickButton_dot, CIwUIElement*)
		IW_UI_CREATE_VIEW_SLOT1(this, "CController", CController, OnClickButton_C, CIwUIElement*)
		IW_UI_CREATE_VIEW_SLOT1(this, "CController", CController, OnClickButton_mc, CIwUIElement*)
		IW_UI_CREATE_VIEW_SLOT1(this, "CController", CController, OnClickButton_mplus, CIwUIElement*)
		IW_UI_CREATE_VIEW_SLOT1(this, "CController", CController, OnClickButton_mminus, CIwUIElement*)
		IW_UI_CREATE_VIEW_SLOT1(this, "CController", CController, OnClickButton_mr, CIwUIElement*)
	}

private:
	void OnClickButton_mc(CIwUIElement*)
	{
		Memory = 0;
	}

	void OnClickButton_mplus(CIwUIElement*)
	{
		Memory += atof(CalcText);
	}

	void OnClickButton_mminus(CIwUIElement*)
	{
		Memory -= atof(CalcText);
	}

	void OnClickButton_mr(CIwUIElement*)
	{
		sprintf(CalcText, "%g", Memory);
		pLabel->SetCaption(CalcText);
	}

	void OnClickButton_plus(CIwUIElement*)
	{
		if (CalcMode && !b_Repeat) OnButtonEqual();

		LastValue = atof(CalcText);
		CalcMode = CALC_MODE_PLUS;
		strcpy(CalcText, "0");
		b_Repeat = false;
	}

	void OnClickButton_minus(CIwUIElement*)
	{
		if (CalcMode && !b_Repeat) OnButtonEqual();

		LastValue = atof(CalcText);
		CalcMode = CALC_MODE_MINUS;
		strcpy(CalcText, "0");
		b_Repeat = false;
	}

	void OnClickButton_times(CIwUIElement*)
	{
		if (CalcMode && !b_Repeat) OnButtonEqual();

		LastValue = atof(CalcText);
		CalcMode = CALC_MODE_TIMES;
		strcpy(CalcText, "0");
		b_Repeat = false;
	}

	void OnClickButton_divide(CIwUIElement*)
	{
		if (CalcMode && !b_Repeat) OnButtonEqual();

		LastValue = atof(CalcText);
		CalcMode = CALC_MODE_DIVIDE;
		strcpy(CalcText, "0");
		b_Repeat = false;
	}

	void OnClickButton_equal(CIwUIElement*)
	{
		//Perform Calculation with set mode
		OnButtonEqual();
	}

	void OnClickButton_plusminus(CIwUIElement*)
	{
		//Flip the sign of the number
		char textbuf[100];
		strcpy(textbuf, CalcText);

		if (textbuf[0] == '-')
		{
			strcpy(CalcText,textbuf+1);
		}
		else
		{
			CalcText[0] = '-';
			strcpy(CalcText+1,textbuf);
		}
		pLabel->SetCaption(CalcText);
	}

	void OnClickButton_dot(CIwUIElement*)
	{
		//Insert the decimal point if it is not already present
		if (!strchr(CalcText, '.'))
		{
			strcat(CalcText, ".");
			pLabel->SetCaption(CalcText);
		}

		pButton_C->SetCaption("C"); 
		g_AC = false;
	}

	void OnClickButton_C(CIwUIElement*)
	{
		//Reset the Calculator Text
		strcpy(CalcText, "0");
		pLabel->SetCaption(CalcText);

		if (g_AC)
		{
			CalcMode	= CALC_MODE_NONE;
			LastValue	= 0;
			PastValue	= 0;
			b_Repeat	= false;
		}

		g_AC = true;
		pButton_C->SetCaption("AC");
	}

	BUTTON(0)
	BUTTON(1)
	BUTTON(2)
	BUTTON(3)
	BUTTON(4)
	BUTTON(5)
	BUTTON(6)
	BUTTON(7)
	BUTTON(8)
	BUTTON(9)

	// Accept number key input
	bool HandleEvent(CIwEvent* pEvent)
	{
		if (pEvent->GetID() == IWUI_EVENT_KEY)
		{
			CIwUIEventKey* pEventKey = (CIwUIEventKey*)pEvent;
			if (!pEventKey->GetPressed())
			{
				s3eKey key = pEventKey->GetKey();
				if ((s3eKey0 <= key) && (key <= s3eKey9))
				{
					int num = (int)key - s3eKey0;
					char buffer[0x10];
					sprintf(buffer, "%d", num);
					OnButtonPress(buffer);
					return true;
				} else if (key == s3eKeyAbsBSK)
					g_Quit = true;
			}
		}
		return CIwUIController::HandleEvent(pEvent);
	}
};

int main()
{
	g_IwTextureAssertPowerOf2 = false;
	g_Quit = false;

	// Initialize Airplay
	IwUIInit();

	{
		CIwUIView view;
		CController controller;
		
		CIwResGroup* pResGroup = IwGetResManager()->LoadGroup("Shortcut2D.group");

		{
			// Cut-off sizes for stylesheet scale decision
			const int32 area_0 = (320*480); // Smaller than this uses small style
			const int32 area_1 = (640*480); // Larger/Equal than this uses large style
			const int32 actual_area = s3eSurfaceGetInt(S3E_SURFACE_HEIGHT)
									 *s3eSurfaceGetInt(S3E_SURFACE_WIDTH);
			int32 style_id = 1;
			if(actual_area<area_0)
				style_id = 0;
			else if(actual_area>=area_1)
				style_id = 2;

			CIwResource* pResource = pResGroup->GetResNamed(s_Stylesheets[style_id], IW_UI_RESTYPE_STYLESHEET);
			IwGetUIStyleManager()->SetStylesheet(IwSafeCast<CIwUIStylesheet*>(pResource));
		}
		
		CIwUIElement* pWidgets = CIwUIElement::CreateFromResource("Calculator");
		view.AddElement(pWidgets);
		view.AddElementToLayout(pWidgets);

		// Reset the Calculator to 0
		strcpy(CalcText, "0");
		pLabel = (CIwUILabel*)pWidgets->GetChildNamed("Label");
		pLabel->SetCaption(CalcText);

		pButton_C = (CIwUIButton*)pWidgets->GetChildNamed("Button_C");
		g_AC = true;
		pButton_C->SetCaption("AC");

		CIwUIButton* button;
		button = (CIwUIButton*)pWidgets->GetChildNamed("Button_divide");
		button->SetCaption("\xc3\xb7"); //UTF8 divide
		button = (CIwUIButton*)pWidgets->GetChildNamed("Button_times");
		button->SetCaption("\xc3\x97"); //UTF8 times
		
		// Ensure layout is valid prior to setting focus element
		view.Layout();

		// Pick an element to have focus by default
		CIwUIElement* pFocusElement = pWidgets->GetChildNamed("Button_equal");
		IwGetUIView()->RequestFocus(pFocusElement);

		while(!g_Quit)
		{
			IwGxClear(IW_GX_COLOUR_BUFFER_F | IW_GX_DEPTH_BUFFER_F);

			IwGetUIController()->Update();
			view.Update(50);
			view.Render();
			
			IwGxFlush();
			IwGxSwapBuffers();
			s3eDeviceYield();
			
			// Wait until something happens
			s3eDeviceYieldUntilEvent();
			s3eKeyboardUpdate();
			s3ePointerUpdate();
			
			// Check for quit request
			g_Quit |= (s3eDeviceCheckQuitRequest()!=0);
		}

		IwGetResManager()->DestroyGroup(pResGroup);
	}

	IwUITerminate();
	return 0;
}
