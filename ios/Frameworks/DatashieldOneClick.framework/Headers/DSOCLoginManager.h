#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 登录错误码定义
 */
typedef NS_ENUM(NSUInteger, DSOCLoginErrorCode) {
    /// 登录成功
    DSOCLoginSuccess,
    /// 密钥错误（ak/sk/token）
    DSOCLoginKeyError,
    /// 服务端数据异常或解析错误
    DSOCLoginDataError,
    /// 网络异常（如超时、无网络等）
    DSOCLoginNetError,
    /// 手机号非法或格式错误
    DSOCLoginPhoneError,
    /// 未知错误
    DSOCLoginErrorUnknown,
};

/**
 * 一键登录管理器
 * 用于配置、展示和处理一键登录及多登录方式
 */
@interface DSOCLoginManager : NSObject

/// 用于展示登录界面的控制器（建议为当前顶层 VC）
@property (nonatomic, weak) UIViewController *presentingViewController;

/// 当前是否支持一键登录功能（根据设备、运营商等综合判断）
@property (nonatomic, assign, readonly) BOOL supportsOneClickLogin;

@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *ak;
@property (nonatomic, copy) NSString *sk;
@property (nonatomic, copy) NSString *phoneOperator;
@property (nonatomic, copy, nullable) NSString *ip;

/// 获取单例对象
+ (instancetype)sharedManager;

/**
 * 设置 SDK 语言
 * @param languageCode BCP-47 格式的语言代码（如@"en"、@"th"）
 */
- (void)setLanguage:(NSString *)languageCode;

/**
 * 设置登录界面主 Logo 图片
 * @param logo 显示在登录弹窗中的 logo 图片（居中显示）
 */
- (void)setLogo:(UIImage *)logo;

/**
 * 初始化 SDK 授权配置
 * @param token 分配的 Token
 * @param ak Access Key
 * @param sk Secret Key
 * 若三者任一为空，将抛出异常或注册失败
 */
- (void)registerWithToken:(NSString *)token ak:(NSString *)ak sk:(NSString *)sk;

/**
 * 设置更多登录方式的图标（如微信、QQ、Apple 登录等）
 * @param icons 图片数组，元素为 UIImage，按顺序展示
 * @param clickHandler 点击图标后的回调，index 表示点击图标索引
 */
- (void)setMoreLoginIcons:(NSArray<UIImage *> *)icons
                  onClick:(void (^)(NSInteger index))clickHandler;

/**
 * 展示一键登录界面
 * @param completion 登录结果回调
 *  - success 是否登录成功
 *  - code 错误码（参见 DSOCLoginErrorCode）
 *  - message 错误说明文字
 */
- (void)showLoginWithCompletion:(void (^)(BOOL success,
                                          DSOCLoginErrorCode code,
                                          NSDictionary *_Nullable payload))completion;

@end


NS_ASSUME_NONNULL_END
