//
//  JYBinderPropertyInfo.m
//  JYBinder
//
//  Created by XJY on 2018/2/24.
//  Copyright © 2018年 JY. All rights reserved.
//

#import "JYBinderPropertyInfo.h"

@implementation JYBinderPropertyInfo

- (instancetype)initWithProperty:(objc_property_t)property {
    if (!property) {
        return nil;
    }
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _property = property;
    const char *name = property_getName(property);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    
    _attributes = property_getAttributes(property);
    
    JYBinderEncodingType type = JYBinderEncodingTypeUnknown;
    
    unsigned int attributesCount = 0;
    
    objc_property_attribute_t *attributes = property_copyAttributeList(property, &attributesCount);
    if (attributes && attributesCount > 0) {
        for (unsigned int i = 0; i < attributesCount; i++) {
            const char *attributeName = attributes[i].name;
            switch (attributeName[0]) {
                case JYBinderTypeCodeType: {
                    if (attributes[i].value) {
                        const char *attributeValue = attributes[i].value;
                        _typeEncoding = [NSString stringWithUTF8String:attributeValue];
                        type |= [self getEncodingType:attributeValue];
                        if ((type & 0xFF) == JYBinderEncodingTypeObject) {
                            size_t length = strlen(attributeValue);
                            if (length > 3) {
                                char name[length - 2];
                                name[length - 3] = '\0';
                                memcpy(name, attributeValue + 2, length - 3);
                                _cls = objc_getClass(name);
                            }
                        }
                    }
                    
                } break;
                    
                case JYBinderTypeCodeVariable: {
                    const char *attributeValue = attributes[i].value;
                    if (attributeValue) {
                        _ivarName = [NSString stringWithUTF8String:attributeValue];
                    }
                    
                } break;
                    
                case JYBinderTypeCodeReadonly: {
                    type |= JYBinderEncodingTypeReadonly;
                } break;
                    
                case JYBinderTypeCodeCopy: {
                    type |= JYBinderEncodingTypeCopy;
                } break;
                    
                case JYBinderTypeCodeRetain: {
                    type |= JYBinderEncodingTypeRetain;
                } break;
                    
                case JYBinderTypeCodeWeak: {
                    type |= JYBinderEncodingTypeWeak;
                } break;
                    
                case JYBinderTypeCodeNonatomic: {
                    type |= JYBinderEncodingTypeNonatomic;
                } break;
                    
                case JYBinderTypeCodeDynamic: {
                    type |= JYBinderEncodingTypeDynamic;
                } break;
                    
                case JYBinderTypeCodeCustomGetter: {
                    type |= JYBinderEncodingTypeCustomGetter;
                    const char *attributeValue = attributes[i].value;
                    if (attributeValue) {
                        _getter = NSSelectorFromString([NSString stringWithUTF8String:attributeValue]);
                    }
                } break;
                    
                case JYBinderTypeCodeCustomSetter: {
                    type |= JYBinderEncodingTypeCustomSetter;
                    const char *attributeValue = attributes[i].value;
                    if (attributeValue) {
                        _setter = NSSelectorFromString([NSString stringWithUTF8String:attributeValue]);
                    }
                } break;
                    
                default:
                    break;
            }
        }
    }
    if (attributes) {
        free(attributes);
        attributes = NULL;
    }
    
    _type = type;
    if (_name.length) {
        if (!_getter) {
            _getter = NSSelectorFromString(_name);
        }
        if (!_setter) {
            _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [_name substringToIndex:1].uppercaseString, [_name substringFromIndex:1]]);
        }
    }
    
    return self;
}

- (JYBinderEncodingType)getEncodingType:(const char *)typeEncoding {
    char *type = (char *)typeEncoding;
    if (!type) {
        return JYBinderEncodingTypeUnknown;
    }
    size_t length = strlen(type);
    if (length <= 0) {
        return JYBinderEncodingTypeUnknown;
    }
    
    JYBinderEncodingType qualifier = JYBinderEncodingTypeUnknown;
    bool prefix = true;
    while (prefix) {
        switch (*type) {
            case JYBinderTypeCodeConst: {
                qualifier |= JYBinderEncodingTypeConst;
                type++;
            } break;
                
            case JYBinderTypeCodeIn: {
                qualifier |= JYBinderEncodingTypeIn;
                type++;
            } break;
                
            case JYBinderTypeCodeInout: {
                qualifier |= JYBinderEncodingTypeInout;
                type++;
            } break;
                
            case JYBinderTypeCodeOut: {
                qualifier |= JYBinderEncodingTypeOut;
                type++;
            } break;
                
            case JYBinderTypeCodeBycopy: {
                qualifier |= JYBinderEncodingTypeBycopy;
                type++;
            } break;
                
            case JYBinderTypeCodeByref: {
                qualifier |= JYBinderEncodingTypeByref;
                type++;
            } break;
                
            case JYBinderTypeCodeOneway: {
                qualifier |= JYBinderEncodingTypeOneway;
                type++;
            } break;
                
            default: {
                prefix = false;
            } break;
        }
    }
    
    length = strlen(type);
    if (length <= 0) {
        return JYBinderEncodingTypeUnknown | qualifier;
    }
    
    switch (*type) {
        case JYBinderTypeCodeChar:
            return JYBinderEncodingTypeChar | qualifier;
        case JYBinderTypeCodeInt:
            return JYBinderEncodingTypeInt | qualifier;
        case JYBinderTypeCodeShort:
            return JYBinderEncodingTypeShort | qualifier;
        case JYBinderTypeCodeLong:
            return JYBinderEncodingTypeLong | qualifier;
        case JYBinderTypeCodeLongLong:
            return JYBinderEncodingTypeLongLong | qualifier;
        case JYBinderTypeCodeUChar:
            return JYBinderEncodingTypeUChar | qualifier;
        case JYBinderTypeCodeUInt:
            return JYBinderEncodingTypeUInt | qualifier;
        case JYBinderTypeCodeUShort:
            return JYBinderEncodingTypeUShort | qualifier;
        case JYBinderTypeCodeULong:
            return JYBinderEncodingTypeULong | qualifier;
        case JYBinderTypeCodeULongLong:
            return JYBinderEncodingTypeULongLong | qualifier;
        case JYBinderTypeCodeFloat:
            return JYBinderEncodingTypeFloat | qualifier;
        case JYBinderTypeCodeDouble:
            return JYBinderEncodingTypeDouble | qualifier;
        case JYBinderTypeCodeLongDouble:
            return JYBinderEncodingTypeLongDouble | qualifier;
        case JYBinderTypeCodeBool:
            return JYBinderEncodingTypeBool | qualifier;
        case JYBinderTypeCodeVoid:
            return JYBinderEncodingTypeVoid | qualifier;
        case JYBinderTypeCodeString:
            return JYBinderEncodingTypeString | qualifier;
        case JYBinderTypeCodeClass:
            return JYBinderEncodingTypeClass | qualifier;
        case JYBinderTypeCodeSEL:
            return JYBinderEncodingTypeSEL | qualifier;
        case JYBinderTypeCodeBit:
            return JYBinderEncodingTypeBit | qualifier;
        case JYBinderTypeCodePointer:
            return JYBinderEncodingTypePointer | qualifier;
        case JYBinderTypeCodeArrayBegin:
            return JYBinderEncodingTypeArray | qualifier;
        case JYBinderTypeCodeStructBegin:
            return JYBinderEncodingTypeStruct | qualifier;
        case JYBinderTypeCodeUnionBegin:
            return JYBinderEncodingTypeUnion | qualifier;
        case JYBinderTypeCodeObject: {
            if (length == 2 && *(type + 1) == JYBinderTypeCodeUnknown) {
                return JYBinderEncodingTypeBlock | qualifier;
            } else {
                return JYBinderEncodingTypeObject | qualifier;
            }
        }
        default:
            return JYBinderEncodingTypeUnknown | qualifier;
    }
}

@end
