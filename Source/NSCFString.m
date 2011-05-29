/* NSCFString.m
   
   Copyright (C) 2010 Free Software Foundation, Inc.
   
   Written by: Stefan Bidigaray
   Date: May, 2011
   
   This file is part of CoreBase.
   
   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; see the file COPYING.LIB.
   If not, see <http://www.gnu.org/licenses/> or write to the 
   Free Software Foundation, 51 Franklin Street, Fifth Floor, 
   Boston, MA 02110-1301, USA.
*/

#include <Foundation/NSObject.h>
#include <Foundation/NSException.h>
#include <Foundation/NSString.h>

#include "CoreFoundation/CFString.h"

/* NSCFString inherits from NSMutableString and doesn't have any ivars
   because it is only an ObjC wrapper around CFString. */
@interface NSCFString : NSMutableString
@end

@implementation NSCFString
- (id) initWithBytes: (const void*) bytes
              length: (NSUInteger) length
            encoding: (NSStringEncoding) encoding
{
  CFAllocatorRef alloc = (CFAllocatorRef)[self zone];
  CFStringEncoding enc = CFStringConvertNSStringEncodingToEncoding (encoding);
  RELEASE(self);
  self = (NSCFString*)CFStringCreateWithBytes (alloc, bytes, length, enc,
    false);
  return self;
}

- (id) initWithBytesNoCopy: (void*) bytes
                    length: (NSUInteger) length
                  encoding: (NSStringEncoding) encoding 
              freeWhenDone: (BOOL) flag
{
  CFAllocatorRef alloc = (CFAllocatorRef)[self zone];
  CFAllocatorRef deallocator = flag ? kCFAllocatorDefault : kCFAllocatorNull;
  CFStringEncoding enc = CFStringConvertNSStringEncodingToEncoding (encoding);
  RELEASE(self);
  self = (NSCFString*)CFStringCreateWithBytesNoCopy (alloc, bytes, length, enc,
    false, deallocator);
  return self;
}

- (id) initWithCharacters: (const unichar*) chars
                   length: (NSUInteger) length
{
  CFAllocatorRef alloc = (CFAllocatorRef)[self zone];
  RELEASE(self);
  self = (NSCFString*)CFStringCreateWithCharacters (alloc, chars, length);
  return self;
}

- (id) initWithCharactersNoCopy: (unichar*) chars
                         length: (NSUInteger) length
                   freeWhenDone: (BOOL) flag
{
  CFAllocatorRef alloc = (CFAllocatorRef)[self zone];
  CFAllocatorRef deallocator = flag ? kCFAllocatorDefault : kCFAllocatorNull;
  RELEASE(self);
  self = (NSCFString*)CFStringCreateWithCharactersNoCopy (alloc, chars, length,
    deallocator);
  return self;
}

- (id) initWithString: (NSString*) string
{
  CFAllocatorRef alloc = (CFAllocatorRef)[self zone];
  RELEASE(self);
  self = (NSCFString*)CFStringCreateWithSubstring (alloc, (CFStringRef)string,
    CFRangeMake(0, CFStringGetLength((CFStringRef)string)));
  return self;
}

- (id) initWithFormat: (NSString*) format
            arguments: (va_list) argList
{
  CFAllocatorRef alloc = (CFAllocatorRef)[self zone];
  RELEASE(self);
  self = (NSCFString*)CFStringCreateWithFormatAndArguments (alloc, NULL,
    (CFStringRef)format, argList);
  return self;
}

- (id) initWithFormat: (NSString*) format
               locale: (id) locale
            arguments: (va_list) argList
{
  if ([locale isKindOfClass: [NSLocale class]])
    return nil; // FIXME
  return (NSCFString*)
    CFStringCreateWithFormatAndArguments (CFAllocatorGetDefault(),
    (CFDictionaryRef)locale, (CFStringRef)format, argList);
}

- (id) initWithData: (NSData*)data
           encoding: (NSStringEncoding)encoding
{
  CFStringEncoding enc = CFStringConvertNSStringEncodingToEncoding (encoding);
  CFAllocatorRef alloc = (CFAllocatorRef)[self zone];
  RELEASE(self);
  self = (NSCFString*)
    CFStringCreateFromExternalRepresentation (alloc, (CFDataRef)data, enc);
  return self;
}

- (NSString*)stringByReplacingOccurrencesOfString: (NSString*)replace
                                       withString: (NSString*)by
                                          options: (NSStringCompareOptions)opts
                                            range: (NSRange)searchRange
{
  return nil; // FIXME
}

- (NSString*) stringByReplacingCharactersInRange: (NSRange)aRange 
                                      withString: (NSString*)by;
{
  return nil; // FIXME
}

- (NSUInteger) length
{
  return (NSUInteger)CFStringGetLength ((CFStringRef)self);
}

- (unichar) characterAtIndex: (NSUInteger) index
{
  return (unichar)CFStringGetCharacterAtIndex ((CFStringRef)self, index);
}

- (void) getCharacters: (unichar*) buffer
                 range: (NSRange) aRange
{
  CFRange cfRange = CFRangeMake (aRange.location, aRange.length);
  CFStringGetCharacters ((CFStringRef)self, cfRange, buffer);
}

- (NSArray*) componentsSeparatedByString: (NSString*) separator
{
  return (NSArray*)
    CFStringCreateArrayBySeparatingStrings (CFAllocatorGetDefault(),
    (CFStringRef)self, (CFStringRef)separator);
}

- (NSRange) rangeOfCharacterFromSet: (NSCharacterSet*) aSet
                            options: (NSUInteger) mask
                              range: (NSRange) aRange
{
  CFRange cfRange = CFRangeMake (aRange.location, aRange.length);
  CFRange ret;
  
  if (!CFStringFindCharacterFromSet ((CFStringRef)self,
      (CFCharacterSetRef)aSet, cfRange, (CFStringCompareFlags)mask,
      &ret))
    ret = CFRangeMake (kCFNotFound, 0);
  
  return NSMakeRange (ret.location, ret.length);
}

- (NSRange) rangeOfString: (NSString*) aString
                  options: (NSUInteger) mask
                    range: (NSRange) aRange
{
  // FIXME: Override this method because NSString doesn't do it right.
  return [self rangeOfString: aString
                     options: mask
                       range: aRange
                      locale: nil];
}

- (NSRange) rangeOfString: (NSString *) aString
                  options: (NSStringCompareOptions) mask
                    range: (NSRange) searchRange
                   locale: (NSLocale *) locale
{
  CFRange cfRange = CFRangeMake (searchRange.location, searchRange.length);
  CFRange ret;
  
  if (!CFStringFindWithOptionsAndLocale ((CFStringRef)self,
      (CFStringRef)aString, cfRange, (CFStringCompareFlags)mask,
      (CFLocaleRef)locale, &ret))
    ret = CFRangeMake (kCFNotFound, 0);
  
  return NSMakeRange (ret.location, ret.length);
}

- (NSRange) rangeOfComposedCharacterSequenceAtIndex: (NSUInteger) anIndex
{
  CFRange cfRange =
    CFStringGetRangeOfComposedCharactersAtIndex ((CFStringRef)self, anIndex);
  return NSMakeRange (cfRange.location, cfRange.length);
}

- (NSDictionary*) propertyListFromStringsFileFormat
{
  // FIXME ???
  return nil;
}

- (NSComparisonResult) compare: (NSString*) aString
                       options: (NSUInteger) mask
                         range: (NSRange) aRange
{
  // FIXME: Another instance of NSString doing it wrong....
  return [self compare: aString options: mask range: aRange locale: nil];
}

- (NSComparisonResult) compare: (NSString*) string 
                       options: (NSUInteger) mask 
                         range: (NSRange) compareRange 
                        locale: (id) locale
{
  CFRange cfRange = CFRangeMake (compareRange.location, compareRange.length);
  if ([locale isKindOfClass: [NSDictionary class]])
    {
      return [super compare: string options: mask range: compareRange
        locale: locale];
    }
  return CFStringCompareWithOptionsAndLocale ((CFStringRef)self,
    (CFStringRef) string, cfRange, (CFStringCompareFlags)mask,
    (CFLocaleRef)locale);
}

- (BOOL) hasPrefix: (NSString*) aString
{
  return CFStringHasPrefix ((CFStringRef)self, (CFStringRef)aString);
}

- (BOOL) hasSuffix: (NSString*) aString
{
  return CFStringHasSuffix ((CFStringRef)self, (CFStringRef)aString);
}

- (BOOL) isEqualToString: (NSString*) aString
{
  return CFStringCompare ((CFStringRef)self, (CFStringRef)aString, 0);
}

- (NSUInteger) hash
{
  return CFHash ((CFTypeRef)self);
}

- (NSString*) commonPrefixWithString: (NSString*) aString
                             options: (NSUInteger) mask
{
  return nil; // FIXME
}

- (NSString*) capitalizedString
{
  return nil;// FIXME
}

- (NSString*) lowercaseString
{
  return nil; // FIXME
}

- (NSString*) uppercaseString
{
  return nil; // FIXME
}

- (const char*) cString
{
  return [self cStringUsingEncoding: NSASCIIStringEncoding];
}

- (const char*) cStringUsingEncoding: (NSStringEncoding) encoding
{
  CFStringEncoding enc = CFStringConvertNSStringEncodingToEncoding (encoding);
  const char *cstr =
    CFStringGetCStringPtr ((CFStringRef)self, enc);
  if (!cstr)
    return NULL; // FIXME
  return cstr;
}

- (BOOL) getCString: (char*) buffer
          maxLength: (NSUInteger) maxLength
           encoding: (NSStringEncoding) encoding
{
  CFStringEncoding enc = CFStringConvertEncodingToNSStringEncoding (encoding);
  return (BOOL)CFStringGetCString ((CFStringRef)self, buffer, maxLength, enc);
}

- (NSUInteger) lengthOfBytesUsingEncoding: (NSStringEncoding) encoding
{
  return 0; // FIXME
}

- (NSUInteger) maximumLengthOfBytesUsingEncoding: (NSStringEncoding) encoding
{
  CFStringEncoding enc = CFStringConvertNSStringEncodingToEncoding (encoding);
  return CFStringGetMaximumSizeForEncoding ([self length], enc);
}

- (NSUInteger) cStringLength
{
  return 0; // FIXME
}

- (float) floatValue
{
  return (float)CFStringGetDoubleValue ((CFStringRef)self);
}

- (int) intValue
{
  return (int)CFStringGetIntValue ((CFStringRef)self);
}

- (double) doubleValue
{
  return CFStringGetDoubleValue ((CFStringRef)self);
}

- (BOOL) boolValue
{
  return (BOOL)CFStringGetIntValue ((CFStringRef)self); //FIXME
}

- (NSInteger) integerValue
{
  return (NSInteger)CFStringGetIntValue ((CFStringRef)self);
}

- (long long) longLongValue
{
  return (long long)CFStringGetIntValue ((CFStringRef)self); // FIXME
}

- (BOOL) canBeConvertedToEncoding: (NSStringEncoding) encoding
{
  // FIXME
  return NO;
}

- (NSData*) dataUsingEncoding: (NSStringEncoding) encoding
         allowLossyConversion: (BOOL) flag
{
  CFStringEncoding enc = CFStringConvertEncodingToNSStringEncoding (encoding);
  return (NSData*)CFStringCreateExternalRepresentation (NULL,
    (CFStringRef)self, enc, flag ? '?' : 0);
}

+ (NSStringEncoding) defaultCStringEncoding
{
  // FIXME ???
  return 0;
}

- (NSStringEncoding) fastestEncoding
{
  CFStringEncoding enc = CFStringGetFastestEncoding ((CFStringRef)self);
  return CFStringConvertEncodingToNSStringEncoding (enc);
}

- (NSStringEncoding) smallestEncoding
{
  CFStringEncoding enc = CFStringGetSmallestEncoding ((CFStringRef)self);
  return CFStringConvertEncodingToNSStringEncoding (enc);
}

- (const char*) fileSystemRepresentation
{
  // FIXME
  return NULL;
}

- (BOOL) getFileSystemRepresentation: (char*) buffer
                           maxLength: (NSUInteger) size
{
  return (BOOL)CFStringGetFileSystemRepresentation ((CFStringRef)self,
    buffer, size);
}

- (NSString*) substringWithRange: (NSRange) aRange
{
  CFRange cfRange = CFRangeMake (aRange.location, aRange.length);
  return (NSString*)CFStringCreateWithSubstring (NULL, (CFStringRef)self,
    cfRange);
}

+ (NSStringEncoding*) availableStringEncodings
{
  // FIXME ???
  return NULL;
}

+ (NSString*) localizedNameOfStringEncoding: (NSStringEncoding) encoding
{
  // FIXME
  return nil;
}

- (void) getLineStart: (NSUInteger *) startIndex
                  end: (NSUInteger *) lineEndIndex
          contentsEnd: (NSUInteger *) contentsEndIndex
             forRange: (NSRange) aRange
{
  CFRange cfRange = CFRangeMake (aRange.location, aRange.length);
  CFStringGetLineBounds ((CFStringRef)self, cfRange, (CFIndex*)startIndex,
    (CFIndex*)lineEndIndex, (CFIndex*)contentsEndIndex);
}

- (const char*) lossyCString
{
  // FIXME
  return NULL;
}

- (NSString*) stringByAddingPercentEscapesUsingEncoding: (NSStringEncoding)e
{
  return nil; // FIXME
}

- (NSString*) stringByPaddingToLength: (NSUInteger)newLength
                           withString: (NSString*)padString
                      startingAtIndex: (NSUInteger)padIndex
{
  return nil; // FIXME: Use CFStringPad()
}

- (NSString*) stringByReplacingPercentEscapesUsingEncoding: (NSStringEncoding)e
{
  return nil; // FIXME
}

- (NSString*) stringByTrimmingCharactersInSet: (NSCharacterSet*)aSet
{
  return nil; // FIXME
}

- (const char *)UTF8String
{
  return NULL; // FIXME
}

- (void) getParagraphStart: (NSUInteger *) startPtr
                       end: (NSUInteger *) parEndPtr
               contentsEnd: (NSUInteger *) contentsEndPtr
                  forRange: (NSRange)range
{
  CFRange cfRange = CFRangeMake (range.location, range.length);
  CFStringGetParagraphBounds ((CFStringRef)self, cfRange, (CFIndex*)startPtr,
    (CFIndex*)parEndPtr, (CFIndex*)contentsEndPtr);
}

- (NSArray *) componentsSeparatedByCharactersInSet: (NSCharacterSet *)separator
{
  return nil; // FIXME
}

- (NSRange) rangeOfComposedCharacterSequencesForRange: (NSRange)range
{
  return NSMakeRange (NSNotFound, 0); // FIXME
}



//
// NSMutableString methods
//
- (id) initWithCapacity: (NSUInteger)capacity
{
  CFAllocatorRef alloc = (CFAllocatorRef)[self zone];
  RELEASE(self);
  self = (NSCFString*)CFStringCreateMutable (alloc, capacity);
  return self;
}

- (void) appendFormat: (NSString*) format, ...
{
  va_list args;
  
  if (format == nil)
    [NSException raise: NSInvalidArgumentException format: @"format is nil."];

  va_start(args, format);
  CFStringAppendFormatAndArguments ((CFMutableStringRef)self, NULL,
    (CFStringRef)format, args);
  va_end (args);
}

- (void) appendString: (NSString*) aString
{
  CFStringAppend ((CFMutableStringRef)self, (CFStringRef)aString);
}

- (void) deleteCharactersInRange: (NSRange) range
{
  CFRange cfRange = CFRangeMake (range.location, range.length);
  CFStringDelete ((CFMutableStringRef)self, cfRange);
}

- (void) insertString: (NSString*) aString atIndex: (NSUInteger) loc
{
  CFStringInsert ((CFMutableStringRef)self, loc, (CFStringRef)aString);
}

- (void) replaceCharactersInRange: (NSRange) range 
                       withString: (NSString*) aString
{
  CFRange cfRange = CFRangeMake (range.location, range.length);
  CFStringReplace ((CFMutableStringRef)self, cfRange, NULL);
}

- (NSUInteger) replaceOccurrencesOfString: (NSString*) replace
                               withString: (NSString*) by
                                  options: (NSUInteger) opts
                                    range: (NSRange) searchRange
{
  CFRange cfRange = CFRangeMake (searchRange.location, searchRange.length);
  if (replace == nil)
    [NSException raise: NSInvalidArgumentException
                format: @"Target string is nil."];
  if (by == nil)
    [NSException raise: NSInvalidArgumentException
                format: @"Replacement is nil."];
  /* FIXME: raise exception for out of range */
  
  return CFStringFindAndReplace ((CFMutableStringRef)self, (CFStringRef)replace,
    (CFStringRef)by, cfRange, (CFOptionFlags)opts);
}

- (void) setString: (NSString*) aString
{
  CFStringReplaceAll ((CFMutableStringRef)self, (CFStringRef)aString);
}
@end
