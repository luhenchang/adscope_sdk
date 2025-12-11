
import {
  Any, MethodCall, MethodResult
} from '@ohos/flutter_ohos';
import {
  ampsAd,
  AMPSDrawAd,
  AMPSDrawAdListener,
  AMPSDrawAdWrapper,
  AMPSNativeInteractiveListener,
  AMPSDrawRenderListener
} from 'xyz.adscope.amps';
import {
  AMPSAdSdkMethodNames,
  AmpsDrawCallbackChannelMethod
} from '../common/common';
import { AdOptionsModule } from '../common/AdOptionsModule';
import { window } from '@kit.ArkUI';
import { AdWrapperManager } from '../native/AdWrapperManager';
import { AMPSEventManager } from '../common/AMPSEventManager';

export class AMPSDrawAdManager {
  private static instance: AMPSDrawAdManager;
  // 使用private修饰符限制访问，并添加明确类型
  private mWindowStage?: window.WindowStage;
  private mDrawAd?: AMPSDrawAd;
  private adItemMap: Map<string,AMPSDrawAdWrapper> = new Map()

  getAdItem(id:string){
    return this.adItemMap.get(id)
  }
  addAdItem(adWrapper: AMPSDrawAdWrapper){
    this.adItemMap.set(adWrapper.adId,adWrapper)
  }



  private mAdWrapperCallBack: AMPSNativeInteractiveListener = {
    onAdShow: (adId?: string | undefined): void => {
      // this.sendMessage(AmpsDrawCallbackChannelMethod.onAdShow, adId)
    },
    onAdExposure: (adId?: string | undefined): void => {
      this.sendMessage(AmpsDrawCallbackChannelMethod.onAdShow, adId)
    },
    onAdClicked: (adId?: string | undefined): void => {
      this.sendMessage(AmpsDrawCallbackChannelMethod.onAdClicked, adId)
    },
    toCloseAd: (adId?: string | undefined): void => {
      if (adId) {
        AdWrapperManager.getInstance().removeAd(adId);
        this.sendMessage(AmpsDrawCallbackChannelMethod.onAdClosed, adId)
      }
    }
  }
  private mRenderCallBack: AMPSDrawRenderListener = {
    renderSuccess: (adWrapper: AMPSDrawAdWrapper): void => {
      this.sendMessage(AmpsDrawCallbackChannelMethod.onRenderSuccess, adWrapper.adId)
      adWrapper.interactCallBack = this.mAdWrapperCallBack;
      adWrapper.videoPlayCallBack = {
        onVideoReady: () => {
          // this.sendMessage(AmpsDrawCallbackChannelMethod.onVideoPlayStart, adWrapper.adId)
        },
        onVideoPlayStart: () => {
          this.sendMessage(AmpsDrawCallbackChannelMethod.onVideoPlayStart, adWrapper.adId)
        },
        onVideoPause: () => {
          this.sendMessage(AmpsDrawCallbackChannelMethod.onVideoPlayPause, adWrapper.adId)
        },
        onVideoResume: () => {
          this.sendMessage(AmpsDrawCallbackChannelMethod.onVideoAdContinuePlay, adWrapper.adId)
        },
        onVideoPlayComplete: () => {
          this.sendMessage(AmpsDrawCallbackChannelMethod.onVideoAdComplete, adWrapper.adId)
        },
        onVideoPlayError: (code, extra) => {
          let adId = adWrapper.adId
          this.sendMessage(AmpsDrawCallbackChannelMethod.onVideoError, { adId, code, extra })
        }
      };

      //需要缓存到单利。使用完毕之后移除
      this.addAdItem(adWrapper);
    },
    renderFailed: (adWrapper: AMPSDrawAdWrapper): void => {
      this.sendMessage(AmpsDrawCallbackChannelMethod.onRenderFail, adWrapper.adId)
    }
  }
  private callback: AMPSDrawAdListener = {
    loadOk: (adItems: AMPSDrawAdWrapper[]): void => {
      const adIdList: string[] = adItems.map(ad => ad.adId);
      //回调给Flutter端
      this.sendMessage(AmpsDrawCallbackChannelMethod.onLoadSuccess, adIdList)
      //render
      adItems.forEach((item) => {
        item.renderCallBack = this.mRenderCallBack;
        item.renderAd();
      })
    },
    loadFail: (code: number, message: string): void => {
      this.sendMessage(AmpsDrawCallbackChannelMethod.onLoadFailure, { code, message })
    }
  };

  public static getInstance(): AMPSDrawAdManager {
    if (!AMPSDrawAdManager.instance) {
      AMPSDrawAdManager.instance = new AMPSDrawAdManager();
    }
    return AMPSDrawAdManager.instance;
  }

  handleMethodCall(call: MethodCall, result: MethodResult) {
    switch (call.method) {
      case AMPSAdSdkMethodNames.drawCreate:
        this.handleCreate(call, result)
        break
      case AMPSAdSdkMethodNames.drawLoad:
        this.handleLoadAd(call, result);
        break;
      case AMPSAdSdkMethodNames.drawGetEcpm:
        const foundWrapper: AMPSDrawAdWrapper | undefined = this.getAdWrapper(call.args);
        const mEcpm = foundWrapper?.getECPM() ?? 0
        result.success(mEcpm);
        break;
      case AMPSAdSdkMethodNames.drawIsReadyAd:
        result.success(this.mDrawAd?.isReadyAd())
        break;
      case AMPSAdSdkMethodNames.drawPauseAd:
        result.success(null);
        break;
      case AMPSAdSdkMethodNames.drawResumeAd:
        result.success(null);
        break;

      default:
        result.success(null);
    }
  }

  private getAdWrapper(arg: ESObject): AMPSDrawAdWrapper | undefined {
    const targetAdId = (arg as Map<string, Any>)["adId"] as string
    return this.getAdItem(targetAdId);
  }

  private handleCreate(call: MethodCall, result: MethodResult): void {
    try {
      const adOption: ampsAd.AdOptions = AdOptionsModule.getAdOptionFromMap(call.args);
      let context = AMPSEventManager.getInstance().getContext()
      this.mWindowStage = context?.windowStage;
      if (this.mWindowStage) {
        let mWindow = this.mWindowStage.getMainWindowSync();
        if (mWindow) {
          this.mDrawAd = new AMPSDrawAd(mWindow.getUIContext(), adOption, this.callback);
        } else {
          result.error('LOAD_FAILED', '获取窗口或UI上下文失败', undefined);
        }
      } else {
        result.error('LOAD_FAILED', 'WindowStage未初始化', undefined);
      }
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined);
    }
  }

  // 处理开屏广告加载
  private handleLoadAd(call: MethodCall, result: MethodResult): void {
    try {
      this.mDrawAd?.load();
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined);
    }
  }

  public sendMessage = (method: string, args?: Any) => {
    AMPSEventManager.getInstance().sendMessageToFlutter(method, args)
  }
}