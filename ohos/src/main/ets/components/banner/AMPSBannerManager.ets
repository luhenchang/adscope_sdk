import { Any, MethodCall, MethodResult } from '@ohos/flutter_ohos';
import { ampsAd, AMPSBannerAd, AMPSBannerAdWrapper } from 'xyz.adscope.amps';
import { AdOptionsModule } from '../common/AdOptionsModule';
import { AMPSEventManager } from '../common/AMPSEventManager';
import { AMPSBannerCallBackChannelMethod, AMPSAdSdkMethodNames } from '../common/common';
import { window } from '@kit.ArkUI';

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

  cleanUp(){
    this.bannerAd = undefined
    this.bannerAdItem = undefined
  }
  handleMethodCall(call: MethodCall, result: MethodResult) {
    switch (call.method) {
      case AMPSAdSdkMethodNames.bannerCreate:
        this.handleCreate(call, result);
        break;
      case AMPSAdSdkMethodNames.bannerLoad:
        this.handleLoadAd(call, result);
        break;
      case AMPSAdSdkMethodNames.bannerPreLoad:
        this.handlePreLoadAd(call, result);
        break;
      case AMPSAdSdkMethodNames.bannerSetSlideTime:
        this.setSlideIntervalTime(result, call.args)
        break
      case AMPSAdSdkMethodNames.bannerGetECPM:
        const mEcpm = this.bannerAdItem?.getECPM() ?? 0
        result.success(mEcpm);
        break;
      case AMPSAdSdkMethodNames.bannerDestroyAd:
        this.cleanUp()
        break;
      case AMPSAdSdkMethodNames.bannerIsReadyAd:
        result.success(this.bannerAd?.isReadyAd() ?? false);
        break;
      default:
        result.success(undefined);
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

              that.bannerAdItem.renderCallBack = {
                renderSuccess(){
                  that.sendMessage(AMPSBannerCallBackChannelMethod.onLoadSuccess)
                },
                renderFailed(code,message){
                  that.sendMessage(AMPSBannerCallBackChannelMethod.onLoadFailure,{code,message})
                }
              }
              that.bannerAdItem.interactCallBack = {
                onAdShow(){
                  that.sendMessage(AMPSBannerCallBackChannelMethod.onAdShow)
                },
                onAdExposure(){
                  that.sendMessage(AMPSBannerCallBackChannelMethod.onAdShow)
                },
                onAdClicked(){
                  that.sendMessage(AMPSBannerCallBackChannelMethod.onAdClicked)
                },
                toCloseAd(){
                  that.sendMessage(AMPSBannerCallBackChannelMethod.onAdClosed)
                }
              }
              that.bannerAdItem.videoPlayCallBack ={
                onVideoReady(){
                  that.sendMessage(AMPSBannerCallBackChannelMethod.onVideoReady)
                },
                onVideoPlayStart(){
                  that.sendMessage(AMPSBannerCallBackChannelMethod.onVideoPlayStart)
                },
                onVideoPause(){
                  that.sendMessage(AMPSBannerCallBackChannelMethod.onVideoPause)
                },
                onVideoResume(){
                  that.sendMessage(AMPSBannerCallBackChannelMethod.onVideoResume)
                },
                onVideoPlayComplete(){
                  that.sendMessage(AMPSBannerCallBackChannelMethod.onVideoPlayEnd)
                },
                onVideoPlayError(code,message){
                  that.sendMessage(AMPSBannerCallBackChannelMethod.onLoadFailure,{code,message})
                }
              }
              ads[0].renderAd()
            },
            loadFail:(code,message)=>{
              that.sendMessage(AMPSBannerCallBackChannelMethod.onLoadFailure,{code,message})
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
  private handlePreLoadAd(call: MethodCall, result: MethodResult): void {
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