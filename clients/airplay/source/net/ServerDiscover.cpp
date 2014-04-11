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

/**
 * @page ExampleS3EZeroConf S3E ZeroConf Example
 * 
 * The following example demonstrate the use of the s3eZeroConf API
 * to connect to the network and list the available services.
 *
 * ZeroConf is an s3e extension and is currently only supported on iPhone.
 * 
 * The main functions used in this example are:
 * - s3eZeroConfStartSearch()
 * - s3eZeroConfStopSearch()
 * - s3eZeroConfPublish()
 * - s3eZeroConfUnpublish()
 * - s3eZeroConfUpdateTxtRecord()
 * 
 * The application uses s3eZeroConf to makes a connection to the network
 * then enumerated the devices and their services that was found on the network.
 *
 * The results list is output to screen using the s3eDebugPrint() 
 * function. 
 *
 * The following graphic illustrates the example output.
 *
 * @image html s3eZeroConfImage.png
 *
 * @include s3eZeroConf.cpp
 */

#include "s3e.h"
#include "s3eExt_ZeroConf.h"
#include <string.h>
#include <stdio.h>

/*
 * Used to record infomation about the services we've discovered
 */
struct Record
{
    char*           m_name;
    char*           m_txt;
    char*           m_ip;
    void*           m_Ref;
    s3eInetAddress  m_addr;
    Record*         m_pNext;
    Record*         m_pPrev;

    void Free()
    {
        if (m_name)
            s3eFree(m_name);
        m_name = 0;

        if (m_txt)
            s3eFree(m_txt);
        m_txt = 0;

        if (m_ip)
            s3eFree(m_ip);
        m_ip = 0;
    }
};

static Record*                  g_ResultList = 0;
static s3eZeroConfPublished*    g_Service = 0;
static s3eZeroConfSearch*       g_Search = 0;
static uint32                   g_Counter = 0;
static uint32                   g_Timer = 75;
static const unsigned char*     g_TxtRecord = 0;

// this call back is issued when an IP address is resolved.
int32 ResolveIPCallback(void* addr, void* userData)
{
    Record* pResult = (Record*)userData;
    Record* pIter = 0;
    char    buf[512];

    // if addr is null then it couldn't resolve the IP address.
    if (!addr)
    {
        uint32 len = snprintf(buf, sizeof(buf), "`x666666ip resolve failed");

        pResult->m_ip = (char*) s3eMalloc(len);

        memcpy(pResult->m_ip, buf, len);

        return 0;
    }

    // we'd better check this record still exists, since it's 
    // possible for it to have been deleted before the DNS came back
    for (pIter = g_ResultList; pIter; pIter = pIter->m_pNext)
        if (pIter == pResult)
            break;

    if (!pIter)
        return 0;  // it's been deleted, so ignore!

    uint32 len = snprintf(buf, sizeof(buf), "`x666666ip %s", s3eInetToString(&pResult->m_addr)) + 1;

    pResult->m_ip = (char*) s3eMalloc(len);

    memcpy(pResult->m_ip, buf, len);

    return 0;
}

// this call back is issued when a new service (matching the query) is discovered
int32 SearchAddCallBack(s3eZeroConfSearch* search, s3eZeroConfAddRecord* rec, void* userData)
{
    char buf[512];
    char buf2[64];

    s3eDebugTracePrintf("SearchAddCallBack: %s %s %d", rec->m_Name, rec->m_Hostname, rec->m_Port);

    // push a new record onto the list
    Record  *pResult = (Record*) s3eMalloc(sizeof(Record));

    pResult->m_pPrev = 0;
    pResult->m_Ref = rec->m_RecordRef;
    pResult->m_pNext = g_ResultList;

    if (g_ResultList)
        g_ResultList->m_pPrev = pResult;

    g_ResultList = pResult;

    // fill it out
    uint32 len = snprintf(buf, sizeof(buf), "`x666666txt '%s'", rec->m_NumTxtRecords ? rec->m_TxtRecords[0] : "") + 1;
    pResult->m_txt = (char*) s3eMalloc(len);
    memcpy(pResult->m_txt, buf, len);   
    
    len = snprintf(buf, sizeof(buf), "`x666666ihp %s", s3eInetNtoa(rec->m_HostIP, buf2, sizeof(buf2))) + 1;    
    pResult->m_ip = (char*) s3eMalloc(len);
    memcpy(pResult->m_ip, buf, len);
    
    len = snprintf(buf, sizeof(buf), "`x666666%s\n@ %s:%d", rec->m_Name, rec->m_Hostname, rec->m_Port) + 1;
    pResult->m_name = (char*) s3eMalloc(len);
    memcpy(pResult->m_name, buf, len);

    return 0;
}

// this call back is issued when a previously discovered service updates it's txtRecord
int32 SearchUpdateCallBack(s3eZeroConfSearch* search, s3eZeroConfUpdateRecord* rec, void* userData)
{
    Record  *pIter;
    char    buf[512];

    for (pIter = g_ResultList; pIter; pIter = pIter->m_pNext)
        if (pIter->m_Ref == rec->m_RecordRef)
            break;

    if (!pIter)
        return 0;

    // fill it out
    uint32 len = snprintf(buf, sizeof(buf), "`x666666txt '%s'", rec->m_NumTxtRecords ? rec->m_TxtRecords[0] : "") + 1;

    s3eFree(pIter->m_txt);

    pIter->m_txt = (char*) s3eMalloc(len);
    memcpy(pIter->m_txt, buf, len);
    return 0;
}

// this call back is issued when a previously discovered service is unregisted
int32 SearchRemoveCallBack(s3eZeroConfSearch* search, void* userRef, void* userData)
{
    Record  *pIter;

    for (pIter = g_ResultList; pIter; pIter = pIter->m_pNext)
        if (pIter->m_Ref == userRef)
            break;

    if (!pIter)
        return 0;

    // remove pResult from the linked list
    if (pIter->m_pNext)
        pIter->m_pNext->m_pPrev = pIter->m_pPrev;

    if (pIter->m_pPrev)
        pIter->m_pPrev->m_pNext = pIter->m_pNext;
    else 
        g_ResultList = pIter->m_pNext;

    // free pResult
    pIter->Free();
    s3eFree(pIter);
    
    return 0;
}

void ExampleInit()
{
    const char* string = "A test txt record!";
    const char* argv[] = { string };

    // create a dummy service
    g_Service = s3eZeroConfPublish(8080, "s3eDummyService", "_http._tcp", 0, 1, argv);

    // search for "_http._tcp" services in domain "local"
    g_Search = s3eZeroConfStartSearch("_http._tcp", 
                        "local", 
                        SearchAddCallBack, 
                        SearchUpdateCallBack, 
                        SearchRemoveCallBack, 
                        0);
}

void ExampleShutDown()
{
    s3eDebugTracePrintf("Stopping search: %p", g_Search);
    s3eZeroConfStopSearch(g_Search);
    s3eZeroConfUnpublish(g_Service);

    Record *pNext;

    // free the results
    for (Record *pIter = g_ResultList; pIter; pIter = pNext)
    {
        pNext = pIter->m_pNext;

        // free pIter
        pIter->Free();
        s3eFree(pIter);
    }

    g_ResultList = 0;
}

void ClearScreen()
{
    uint16* screen = (uint16*)s3eSurfacePtr();
    int32 width = s3eSurfaceGetInt(S3E_SURFACE_WIDTH);
    int32 height = s3eSurfaceGetInt(S3E_SURFACE_HEIGHT);
    int32 pitch = s3eSurfaceGetInt(S3E_SURFACE_PITCH);

    for (int y = 0; y < height; y++)
        for (int x = 0; x < width; x++)
            screen[y * pitch/2 + x] = 0;
}

bool ExampleUpdate()
{  
    if (g_Timer == 0)
    {
        g_Timer = 75;

        // create a new txtRecord
        char                    txtRec[100];

        snprintf(txtRec, sizeof(txtRec),  "txt record #%u!", g_Counter++);

        const char*             argv[] = { txtRec };

        if (g_TxtRecord)
            s3eFree((void*)g_TxtRecord);
        g_TxtRecord = 0;

        // update the txt record
        s3eZeroConfUpdateTxtRecord(g_Service, 1, argv);
    }
    else
        g_Timer--;

    return true;
}

void ExampleRender()
{
    const int   textHeight = s3eDebugGetInt(S3E_DEBUG_FONT_SIZE_HEIGHT);
    int         y = 50;

    // create a winsock event to go with this socket for use with WSAWaitForMultipleEvents
    for (Record *pIter = g_ResultList; pIter; pIter = pIter->m_pNext)
    {
        if (pIter->m_name)
        {
            s3eDebugPrint(10, y, pIter->m_name, 0);
            y += textHeight * 2;
        }

        if (pIter->m_ip)
        {
            s3eDebugPrint(10, y, pIter->m_ip, 0);
            y += textHeight;
        }

        if (pIter->m_txt)
        {
            s3eDebugPrint(10, y, pIter->m_txt, 0);
            y += textHeight;
        }

        y += textHeight;
    }
} 
