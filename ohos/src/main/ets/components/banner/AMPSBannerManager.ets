import { Any, MethodCall, MethodResult } from '@ohos/flutter_ohos';
import { ampsAd, AMPSBannerAd, AMPSRewardVideoListener, AMPSBannerAdWrapper } from 'xyz.adscope.amps';
import { AdOptionsModule } from '../common/AdOptionsModule';
import { AMPSEventManager } from '../common/AMPSEventManager';
import { AMPSAdCallBackChannelMethod, AMPSAdSdkMethodNames } from '../common/common';
import { window } from '@kit.ArkUI';
import { thirdPaymentService } from '@kit.PaymentKit';

export class AMPSBannerManager{


  private static instance?: AMPSBannerManager
  private constructor() {}
  static getInstance(){
    if (!AMPSBannerManager.instance) {
      AMPSBannerManager.instance  = new AMPSBannerManager()
    }
    return AMPSBannerManager.instance!
  }

  private bannerAd?: AMPSBannerAd
  private bannerAdItem?: AMPSBannerAdWrapper
  getBannerAdItem(){
    return this.bannerAdItem
  }

  private callBack: AMPSRewardVideoListener = {
    onLoadSuccess: (): void => {
      this.sendMessage(AMPSAdCallBackChannelMethod.onLoadSuccess);
      this.sendMessage(AMPSAdCallBackChannelMethod.onRenderOk)
    },
    onLoadFailure: (code: number, message: string): void => {
      this.sendMessage(AMPSAdCallBackChannelMethod.onLoadFailure,{ code, message });
    },
    onAdDidShow: (): void => {
      this.sendMessage(AMPSAdCallBackChannelMethod.onAdShow);
      this.sendMessage(AMPSAdCallBackChannelMethod.onAdExposure);
    },
    onAdClicked: (): void => {
      this.sendMessage(AMPSAdCallBackChannelMethod.onAdClicked);
    },
    onAdClosed: (): void => {
      this.sendMessage(AMPSAdCallBackChannelMethod.onAdClosed);
    },
    onVideoPlayStart: (): void => {
      this.sendMessage(AMPSAdCallBackChannelMethod.onVideoPlayStart);
    },
    onVideoPlayEnd: (): void => {
      this.sendMessage(AMPSAdCallBackChannelMethod.onVideoPlayEnd);
    },
    onVideoPlayError: (code: number, message: string): void => {
      this.sendMessage(AMPSAdCallBackChannelMethod.onVideoPlayError,{ code, message });
    },
    onVideoSkipToEnd: (playDurationMs?: number | undefined): void => {
      this.sendMessage(AMPSAdCallBackChannelMethod.onVideoSkipToEnd,{playDurationMs});
    },
    onAdReward: (): void => {
      this.sendMessage(AMPSAdCallBackChannelMethod.onAdReward);
    }
  }

  handleMethodCall(call: MethodCall, result: MethodResult) {
    switch (call.method) {
      case AMPSAdSdkMethodNames.rewardVideoCreate:
        this.handleCreate(call, result);
        break;
      case AMPSAdSdkMethodNames.rewardVideoLoad:
        this.handleLoadAd(call, result);
        break;
      case AMPSAdSdkMethodNames.bannerSetSlideTime:
        this.setSlideIntervalTime(result, call.args)
        break
      case AMPSAdSdkMethodNames.rewardVideoGetECPM:
        const mEcpm = this.bannerAdItem?.getECPM() ?? 0
        result.success(mEcpm);
        break;
      case AMPSAdSdkMethodNames.rewardVideoIsReadyAd:
        result.success(this.bannerAd?.isReadyAd() ?? false);
        break;
      default:
        result.notImplemented();
    }
  }
  mWindowStage?: window.WindowStage
  private handleCreate(call: MethodCall, result: MethodResult): void {
    try {
      const adOption: ampsAd.AdOptions = AdOptionsModule.getAdOptionFromMap(call.args);
      let context = AMPSEventManager.getInstance().getContext()
      this.mWindowStage = context?.windowStage;
      if (this.mWindowStage) {
        let mWindow = this.mWindowStage.getMainWindowSync();
        if (mWindow) {
          let that = this
          this.bannerAd = new AMPSBannerAd(mWindow.getUIContext(), adOption, {
            loadOk:(ads)=>{
              that.bannerAdItem = ads[0]
              this.sendMessage(AMPSAdCallBackChannelMethod.onLoadSuccess)
              that.bannerAdItem.renderCallBack = {
                renderSuccess(){
                  this.sendMessage(AMPSAdCallBackChannelMethod.onRenderOk)
                },
                renderFailed(code,message){
                  this.sendMessage(AMPSAdCallBackChannelMethod.onRenderFailure,{code,message})
                }
              }
              that.bannerAdItem.interactCallBack = {
                onAdShow(){
                  this.sendMessage(AMPSAdCallBackChannelMethod.onAdShow)
                },
                onAdExposure(){
                  this.sendMessage(AMPSAdCallBackChannelMethod.onAdExposure)
                },
                onAdClicked(){
                  this.sendMessage(AMPSAdCallBackChannelMethod.onAdClicked)
                },
                toCloseAd(){
                  this.sendMessage(AMPSAdCallBackChannelMethod.onAdClosed)
                }
              }
              that.bannerAdItem.videoPlayCallBack ={
                onVideoReady(){
                  this.sendMessage(AMPSAdCallBackChannelMethod)
                },
                onVideoPlayStart(){

                },
                onVideoPause(){

                },
                onVideoResume(){

                },
                onVideoPlayComplete(){

                },
                onVideoPlayError(){

                }
              }

            },
            loadFail:(code,message)=>{
              this.sendMessage(AMPSAdCallBackChannelMethod.onLoadFailure,{code,message})
            }
          });


        } else {
          result.error('LOAD_FAILED', '获取窗口或UI上下文失败', undefined);
        }
      } else {
        result.error('LOAD_FAILED', 'WindowStage未初始化', undefined);
      }
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined);
    }
    result.success(true)
  }
  // 处理开屏广告加载
  private handleLoadAd(call: MethodCall, result: MethodResult): void {
    try {
      this.bannerAd?.load();
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`,undefined);
    }
    result.success(true)
  }

  // 处理开屏广告显示
  private setSlideIntervalTime(result: MethodResult, args: Any): void {
    try {
      if (args as number) {
        let time = args as number
        this.bannerAdItem?.setSlideIntervalTime(time)
      } else {
        result.error('SHOW_FAILED', '广告未加载或WindowStage不存在',undefined);
      }
    } catch (error) {
      result.error('SHOW_EXCEPTION', `显示广告异常: ${error instanceof Error ? error.message : error}`,undefined);
    }
    result.success(true)
  }

  public sendMessage = (method: string, args?: Any) => {
    AMPSEventManager.getInstance().sendMessageToFlutter(method, args)
  }
}