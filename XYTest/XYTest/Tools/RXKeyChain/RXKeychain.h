//
//  DeveloperLx
//  LxKeychain.h
//

/* -------------------- OSStatus probably value --------------------
    errSecSuccess               = 0,       No error.
    errSecUnimplemented         = -4,      Function or operation not implemented.
    errSecIO                    = -36,     I/O error (bummers)
    errSecOpWr                  = -49,     file already open with with write permission
    errSecParam                 = -50,     One or more parameters passed to a function where not valid.
    errSecAllocate              = -108,    Failed to allocate memory.
    errSecUserCanceled          = -128,    User canceled the operation.
    errSecBadReq                = -909,    Bad parameter or invalid state for operation.
    errSecInternalComponent     = -2070,
    errSecNotAvailable          = -25291,  No keychain is available. You may need to restart your computer.
    errSecDuplicateItem         = -25299,  The specified item already exists in the keychain.
    errSecItemNotFound          = -25300,  The specified item could not be found in the keychain.
    errSecInteractionNotAllowed = -25308,  User interaction is not allowed.
    errSecDecode                = -26275,  Unable to decode the provided data.
    errSecAuthFailed            = -25293,  The user name or passphrase you entered is not correct.
*/

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

#define LX_UNAVAILABLE(msg) __attribute__((unavailable(msg)))

typedef NSString * (^ EncrytionBlock)(NSString *);
/*
 *  Can be customed by yourself. Default use md5.
 */
static EncrytionBlock LxKeychainEncryptionBlock = ^(NSString * string) {
    const char * cPlaintext = string.UTF8String;
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cPlaintext, (CC_LONG)strlen(cPlaintext), result);
    NSMutableString * hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [NSString stringWithString:hash.lowercaseString];
};

@interface RXKeychain : NSObject
//插入或更新一个   账号/密码   对：
+ (OSStatus)insertOrUpdatePairsOfUsername:(NSString *)username password:(NSString *)password;

//删除某个用户名的密码：
+ (OSStatus)cleanPasswordForUsername:(NSString *)username;

//删除此对  账号/密码：
+ (OSStatus)deletePairsByUsername:(NSString *)username;

//该用户名对应的密码：
+ (NSString *)passwordForUsername:(NSString *)username;

//判断这个密码是不是对应用户名的密码：
+ (BOOL)password:(NSString *)password isCorrectToUsername:(NSString *)username;

//已保存的所有    用户名：
+ (NSArray *)savedUsernameArray;

//仍存在KeyChain里的，最后一次操作的用户名：
+ (NSString *)lastestUpdatedUsername;

//保存你想保存的数据data：
+ (OSStatus)saveData:(id<NSCoding>)data forService:(NSString *)service;

//找到你上面保存的数据data：
+ (id<NSCoding>)fetchDataOfService:(NSString *)service;

//删除你上面保存的数据data
+ (OSStatus)deleteService:(NSString *)service;

//设备唯一标识符：
+ (NSString *)deviceUniqueIdentifer;

#pragma mark - Unavailable

- (instancetype)init LX_UNAVAILABLE("LxKeychain cannot be initialized!");
- (instancetype)initWithCoder:(NSCoder *)aDecoder LX_UNAVAILABLE("LxKeychain cannot be initialized!");

@end
