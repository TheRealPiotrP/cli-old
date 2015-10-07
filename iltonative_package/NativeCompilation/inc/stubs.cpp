//
// Intrinsic
//
#if 0
void System::Runtime::RuntimeImports::memmove_0(unsigned char *, unsigned char *, int)
{
    throw 42;
}

double System::Runtime::RuntimeImports::sqrt(double value)
{
    return sqrt(value);
}
#endif
//
// BoundsChecking
//
void ThrowRangeOverflowException();
unsigned short System::String::get_Chars(class System::String *pString, int index)
{
    if ((uint32_t)index >= (uint32_t)pString->m_stringLength)
        ThrowRangeOverflowException();
    return *(&pString->m_firstChar + index);
}


#if 0
//
// unattributed, no body method
//
void System::Buffer::BlockCopy(class System::Array * src, int srcOfs, class System::Array * dst, int dstOfs, int count)
{
    // TODO: Argument validation
    memmove((uint8_t*)dst + 2 * sizeof(void*) + dstOfs, (uint8_t*)src + 2 * sizeof(void*) + srcOfs, count);
}
#endif

extern "C" int32_t GetLocaleInfoEx(System::String*, uint32_t, intptr_t, int32_t)
{
	throw 42;
}

#if 0
typedef int (*pfnMain)(System::String__Array * args);

int Internal::Runtime::Loader::LoaderImage::Call(__int64 p, class System::String__Array * args)
{
    return ((pfnMain)p)(args);
}
#endif

System::String* System::Runtime::RuntimeImports::RhNewArrayAsString(System::EETypePtr type, int len)
{
	return (System::String*)__allocate_string(len);
}

#if 0
uint8_t System::Runtime::RuntimeImports::AreTypesEquivalent(System::EETypePtr pType1, System::EETypePtr pType2)
{
	if (pType1.m_value == pType2.m_value)
	{
		return 1;
	}

	throw 42;
}
#endif