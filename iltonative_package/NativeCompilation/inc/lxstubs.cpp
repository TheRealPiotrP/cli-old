#include "common.h"
#include <malloc.h>

extern "C" void LCMapStringEx(void*, uint32_t, void*, int32_t, intptr_t, int32_t, intptr_t, intptr_t, intptr_t)
{
	throw 42;
}

extern "C" int32_t WideCharToMultiByte(uint32_t CodePage, uint32_t dwFlags, uint16_t* lpWideCharStr, int32_t cchWideChar, intptr_t lpMultiByteStr, int32_t cbMultiByte, intptr_t lpDefaultChar, intptr_t lpUsedDefaultChar)
{
	throw 42;
}

extern "C" void CoTaskMemFree(void* m)
{
	free(m);
}

extern "C" intptr_t CoTaskMemAlloc(intptr_t size)
{
	return (intptr_t)malloc(size);
}
