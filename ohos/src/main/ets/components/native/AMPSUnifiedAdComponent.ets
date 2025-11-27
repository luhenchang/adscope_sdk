import { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import {
  AMPSNativeAdWrapper,
  AMPSArrayList,
  AMPSAdItemClickType,
  AMPSBuildNativeAdVideoView,
  AMPSNativeContainer
} from 'xyz.adscope.amps';
import { AdClickIdType, AdClickType, NativeUnifiedBaseChild, NativeUnifiedModule } from '../native/UnifiedNativeModule';
import { OhosPlatformUnifiedView } from './OhosPlatformUnifiedView';
import { AdWrapperManager } from '../native/AdWrapperManager';
import util from '@ohos.util';

@Component
export struct AMPSUnifiedAdComponent {
  private clickIds = new AMPSArrayList<string>();
  private creativeViewIds = new AMPSArrayList<string>()
  @Prop params: Params
  @Prop adId: string
  @State customView: OhosPlatformUnifiedView = this.params.platformView as OhosPlatformUnifiedView
  @State wrapper: AMPSNativeAdWrapper | undefined = undefined
  @State closeAd: boolean = false
  @Prop unifiedModule?: NativeUnifiedModule = undefined
  private rootComponentId: string = util.generateRandomUUID();

  aboutToAppear(): void {
    this.creativeViewIds.clear();
    this.wrapper = AdWrapperManager.getInstance().getAd(this.adId)
  }

  @Builder
  buildASNPBody(wrapper: AMPSNativeAdWrapper) {
    if (this.unifiedModule?.initialized) {
      Stack() {
        Column() {
          Stack() {
            if (this.unifiedModule?.mainImgChildren && wrapper.getMainImageUrl()) {
              Image(wrapper.getMainImageUrl())
                .backgroundColor(this.unifiedModule?.mainImgChildren.backgroundColor)
                .height(this.unifiedModule?.mainImgChildren.height)
                .width(this.unifiedModule?.mainImgChildren.width)
                .offset({ x: this.unifiedModule?.mainImgChildren.x, y: this.unifiedModule?.mainImgChildren.y })
                .id(this.getClickIdTypeIsClick(this.unifiedModule?.mainImgChildren) ?
                  this.clickIds.addAdId(util.generateRandomUUID()) :
                  this.creativeViewIds.addAdId(util.generateRandomUUID()))
                .onClick((event) => {
                  let clickType: AMPSAdItemClickType =
                    this.getAdItemClickType(this.unifiedModule?.mainImgChildren?.clickType);
                  if (clickType != AMPSAdItemClickType.NONE) {
                    wrapper.getClickHandler()(this, event, clickType)
                  }
                })
            }
            if (this.unifiedModule?.videoChildren && wrapper.getVideoUrl()) {
              Column() {
                AMPSBuildNativeAdVideoView(wrapper)
              }
              .width(this.unifiedModule?.videoChildren?.width)
              .height(this.unifiedModule?.videoChildren.height)
              .offset({
                x: this.unifiedModule?.videoChildren?.x,
                y: this.unifiedModule?.videoChildren?.y
              })
            }
            if (this.unifiedModule?.titleChildren && wrapper.getTitle()) {
              Text(wrapper.getTitle())
                .fontSize(this.unifiedModule?.titleChildren.fontSize)
                .fontColor(this.unifiedModule?.titleChildren.color)
                .offset({ x: this.unifiedModule?.titleChildren.x, y: this.unifiedModule?.titleChildren.y })
                .id(this.getClickIdTypeIsClick(this.unifiedModule?.titleChildren) ?
                  this.clickIds.addAdId(util.generateRandomUUID()) :
                  this.creativeViewIds.addAdId(util.generateRandomUUID()))
                .onClick((event) => {
                  let clickType: AMPSAdItemClickType =
                    this.getAdItemClickType(this.unifiedModule?.titleChildren?.clickType);
                  if (clickType != AMPSAdItemClickType.NONE) {
                    wrapper.getClickHandler()(this, event, clickType)
                  }
                })
            }
            if (this.unifiedModule?.descChildren && wrapper.getDescription()) {
              Text(wrapper.getDescription())
                .width(this.unifiedModule?.descChildren?.width)
                .fontSize(this.unifiedModule?.descChildren.fontSize)
                .fontColor(this.unifiedModule?.descChildren.color)
                .offset({ x: this.unifiedModule?.descChildren.x, y: this.unifiedModule?.descChildren.y })
                .id(this.getClickIdTypeIsClick(this.unifiedModule?.descChildren) ?
                  this.clickIds.addAdId(util.generateRandomUUID()) :
                  this.creativeViewIds.addAdId(util.generateRandomUUID()))
                .onClick((event) => {
                  let clickType: AMPSAdItemClickType =
                    this.getAdItemClickType(this.unifiedModule?.descChildren?.clickType);
                  if (clickType != AMPSAdItemClickType.NONE) {
                    wrapper.getClickHandler()(this, event, clickType)
                  }
                })
            }
            if (this.unifiedModule?.appIconChildren && wrapper.getLogoUrl()) {
              Image(wrapper.getLogoUrl())
                .width(this.unifiedModule?.appIconChildren.width)
                .height(this.unifiedModule?.appIconChildren.height)
                .offset({ x: this.unifiedModule?.appIconChildren.x, y: this.unifiedModule?.appIconChildren.y })
                .id(this.getClickIdTypeIsClick(this.unifiedModule?.appIconChildren) ?
                  this.clickIds.addAdId(util.generateRandomUUID()) :
                  this.creativeViewIds.addAdId(util.generateRandomUUID()))
                .onClick((event) => {
                  let clickType: AMPSAdItemClickType =
                    this.getAdItemClickType(this.unifiedModule?.appIconChildren?.clickType);
                  if (clickType != AMPSAdItemClickType.NONE) {
                    wrapper.getClickHandler()(this, event, clickType)
                  }
                })
            }
            if (this.unifiedModule?.actionButtonChildren && wrapper.getActionText()) {
              Text(wrapper.getActionText())
                .width(this.unifiedModule?.actionButtonChildren.width)
                .height(this.unifiedModule?.actionButtonChildren.height)
                .fontSize(this.unifiedModule?.actionButtonChildren.fontSize)
                .textAlign(TextAlign.Center)
                .offset({ x: this.unifiedModule?.actionButtonChildren.x, y: this.unifiedModule?.actionButtonChildren.y })
                .backgroundColor(this.unifiedModule?.actionButtonChildren.backgroundColor)
            }
            if (this.unifiedModule?.closeIconChildren && this.unifiedModule?.closeIconChildren.imagePath) {
              Image($rawfile(`flutter_assets/${this.unifiedModule?.closeIconChildren.imagePath}`))
                .width(this.unifiedModule?.closeIconChildren.width)
                .height(this.unifiedModule?.closeIconChildren.height)
                .offset({ x: this.unifiedModule?.closeIconChildren.x, y: this.unifiedModule?.closeIconChildren.y })
                .id(this.getClickIdTypeIsClick(this.unifiedModule?.descChildren) ?
                  this.clickIds.addAdId(util.generateRandomUUID()) :
                  this.creativeViewIds.addAdId(util.generateRandomUUID()))
                .onClick((event) => {
                  wrapper.getClickHandler()(this, event, AMPSAdItemClickType.CLOSE)
                })
            }
          }
          .backgroundColor(this.unifiedModule?.backgroundColor)
          .alignContent(Alignment.TopStart)
          .width('100%')
          .height('100%')
        }
        .alignItems(HorizontalAlign.Center)
        .height(this.unifiedModule?.height)
        .width(this.unifiedModule?.width)
      }
      .alignContent(Alignment.Center)
      .width("100%")
    }
  }

  getClickIdTypeIsClick(mainImgChildren: NativeUnifiedBaseChild) {
    return mainImgChildren.clickType && mainImgChildren.clickIdType === AdClickIdType.CLICK
  }

  build() {
    if (this.wrapper) {
      AMPSNativeContainer({
        mNativeWrapper: this.wrapper,
        buildContent: () => {
          this.buildASNPBody(this.wrapper)
        }
      }).id(this.rootComponentId)
        .onAppear(() => {
          this.wrapper?.prepare(this.rootComponentId, this.getUIContext(), this.clickIds, this.creativeViewIds)
        })
    }
  }

  private getAdItemClickType(inClickType?: AdClickType) {
    let clickType: AMPSAdItemClickType = AMPSAdItemClickType.NONE;
    if (inClickType === AdClickType.CLICK) {
      clickType = AMPSAdItemClickType.CLICK;
    } else if (inClickType === AdClickType.COMPLAIN) {
      clickType = AMPSAdItemClickType.COMPLAIN;
    } else if (inClickType === AdClickType.CLOSE) {
      clickType = AMPSAdItemClickType.CLOSE;
    } else if (inClickType === AdClickType.LOGO) {
      clickType = AMPSAdItemClickType.LOGO;
    }
    return clickType;
  }
}
