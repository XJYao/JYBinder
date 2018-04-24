//
//  JYBinderPropertyInfo.h
//  JYBinder
//
//  Created by XJY on 2018/2/24.
//  Copyright © 2018年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

//#define _C_ATOM     '%'
//#define _C_VECTOR   '!'

typedef enum : char {
    JYBinderTypeCodeUnknown = _C_UNDEF,        //unknown type
    JYBinderTypeCodeChar = _C_CHR,             //char / int8 / BOOL
    JYBinderTypeCodeInt = _C_INT,              //int32
    JYBinderTypeCodeShort = _C_SHT,            //short / int16
    JYBinderTypeCodeLong = _C_LNG,             //long / is treated as a 32-bit quantity on 64-bit programs.
    JYBinderTypeCodeLongLong = _C_LNG_LNG,     //long long / int64
    JYBinderTypeCodeUChar = _C_UCHR,           //unsigned char / unsigned int8
    JYBinderTypeCodeUInt = _C_UINT,            //unsigned int
    JYBinderTypeCodeUShort = _C_USHT,          //unsigned short / unsigned int16
    JYBinderTypeCodeULong = _C_ULNG,           //unsigned long
    JYBinderTypeCodeULongLong = _C_ULNG_LNG,   //unsigned long long / unsigned int64
    JYBinderTypeCodeFloat = _C_FLT,            //float
    JYBinderTypeCodeDouble = _C_DBL,           //double
    JYBinderTypeCodeLongDouble = 'D',          //long double
    JYBinderTypeCodeBool = _C_BOOL,            //a C++ bool or a C99 _Bool
    JYBinderTypeCodeVoid = _C_VOID,            //void
    JYBinderTypeCodeString = _C_CHARPTR,       //a character string (char *)
    JYBinderTypeCodeObject = _C_ID,            //an object (whether statically typed or typed id)
    JYBinderTypeCodeClass = _C_CLASS,          //class
    JYBinderTypeCodeSEL = _C_SEL,              //SEL
    JYBinderTypeCodeBit = _C_BFLD,             //bit num
    JYBinderTypeCodePointer = _C_PTR,          //pointer
    JYBinderTypeCodeArrayBegin = _C_ARY_B,     //array begin
    JYBinderTypeCodeArrayEnd = _C_ARY_E,       //array end
    JYBinderTypeCodeStructBegin = _C_STRUCT_B, //struct begin
    JYBinderTypeCodeStructEnd = _C_STRUCT_E,   //struct end
    JYBinderTypeCodeUnionBegin = _C_UNION_B,   //union begin
    JYBinderTypeCodeUnionEnd = _C_UNION_E,     //union end
    
    JYBinderTypeCodeType = 'T',     //type
    JYBinderTypeCodeVariable = 'V', //Instance variable
    
    JYBinderTypeCodeConst = _C_CONST, //const
    JYBinderTypeCodeIn = 'n',         //in
    JYBinderTypeCodeInout = 'N',      //inout
    JYBinderTypeCodeOut = 'o',        //out
    JYBinderTypeCodeBycopy = 'O',     //bycopy
    JYBinderTypeCodeByref = 'R',      //byref
    JYBinderTypeCodeOneway = 'V',     //oneway
    
    JYBinderTypeCodeReadonly = 'R',     //readonly
    JYBinderTypeCodeCopy = 'C',         //copy
    JYBinderTypeCodeRetain = '&',       //retain
    JYBinderTypeCodeNonatomic = 'N',    //nonatomic
    JYBinderTypeCodeCustomGetter = 'G', //getter G<name>
    JYBinderTypeCodeCustomSetter = 'S', //setter S<name>
    JYBinderTypeCodeDynamic = 'D',      //@dynamic
    JYBinderTypeCodeWeak = 'W',         //weak
} JYBinderTypeCode;

typedef NS_OPTIONS(NSUInteger, JYBinderEncodingType) {
    JYBinderEncodingTypeUnknown = 0,
    JYBinderEncodingTypeChar,
    JYBinderEncodingTypeInt,
    JYBinderEncodingTypeShort,
    JYBinderEncodingTypeLong,
    JYBinderEncodingTypeLongLong,
    JYBinderEncodingTypeUChar,
    JYBinderEncodingTypeUInt,
    JYBinderEncodingTypeUShort,
    JYBinderEncodingTypeULong,
    JYBinderEncodingTypeULongLong,
    JYBinderEncodingTypeFloat,
    JYBinderEncodingTypeDouble,
    JYBinderEncodingTypeLongDouble,
    JYBinderEncodingTypeBool,
    JYBinderEncodingTypeVoid,
    JYBinderEncodingTypeString,
    JYBinderEncodingTypeObject,
    JYBinderEncodingTypeClass,
    JYBinderEncodingTypeSEL,
    JYBinderEncodingTypeArray,
    JYBinderEncodingTypeStruct,
    JYBinderEncodingTypeUnion,
    JYBinderEncodingTypeBit,
    JYBinderEncodingTypePointer,
    JYBinderEncodingTypeBlock,
    
    JYBinderEncodingTypeConst = 1 << 8,
    JYBinderEncodingTypeIn = 1 << 9,
    JYBinderEncodingTypeInout = 1 << 10,
    JYBinderEncodingTypeOut = 1 << 11,
    JYBinderEncodingTypeBycopy = 1 << 12,
    JYBinderEncodingTypeByref = 1 << 13,
    JYBinderEncodingTypeOneway = 1 << 14,
    
    JYBinderEncodingTypeReadonly = 1 << 16,
    JYBinderEncodingTypeCopy = 1 << 17,
    JYBinderEncodingTypeRetain = 1 << 18,
    JYBinderEncodingTypeWeak = 1 << 19,
    JYBinderEncodingTypeNonatomic = 1 << 20,
    JYBinderEncodingTypeDynamic = 1 << 21,
    JYBinderEncodingTypeCustomGetter = 1 << 22,
    JYBinderEncodingTypeCustomSetter = 1 << 23,
};

@interface JYBinderPropertyInfo : NSObject

@property (nonatomic, assign, readonly) objc_property_t property ;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, assign, readonly) JYBinderEncodingType type;
@property (nonatomic, copy, readonly) NSString *typeEncoding;
@property (nonatomic, strong, readonly) NSString *ivarName;
@property (nonatomic, assign, readonly) Class cls;
@property (nonatomic, assign, readonly) SEL getter;
@property (nonatomic, assign, readonly) SEL setter;
@property (nonatomic, readonly) const char *attributes;

- (instancetype)initWithProperty:(objc_property_t)property;

@end
