package xyz.adscope.adscope_sdk.data

import android.util.Log
import java.io.Serializable
import kotlin.collections.get

//自渲染View结构类
sealed class NativeUnifiedChild : Serializable {
    // 提取所有子组件的通用属性
    abstract val x: Double?
    abstract val y: Double?

    // 1. 主图组件
    data class MainImage(
        override val x: Double? = null,
        override val y: Double? = null,
        val clickType: Int? = null,
        val clickIdType: Int? = null,
        val width: Double? = null,
        val height: Double? = null,
        val backgroundColor: String? = null
    ) : NativeUnifiedChild()

    // 2. 标题组件
    data class Title(
        override val x: Double? = null,
        override val y: Double? = null,
        val clickType: Int? = null,
        val clickIdType: Int? = null,
        val fontSize: Double? = null,
        val color: String? = null,
        val maxLines: Int?,
        val ellipsize: Int?
    ) : NativeUnifiedChild()

    // 3. 描述组件
    data class Description(
        override val x: Double? = null,
        override val y: Double? = null,
        val clickType: Int? = null,
        val clickIdType: Int? = null,
        val fontSize: Double? = null,
        val color: String? = null,
        val width: Double? = null,
        val maxLines: Int?,
        val ellipsize: Int?
    ) : NativeUnifiedChild()

    // 4. 动作按钮
    data class ActionButton(
        override val x: Double? = null,
        override val y: Double? = null,
        val clickType: Int? = null,
        val clickIdType: Int? = null,
        val fontSize: Double? = null,
        val fontColor: String? = null,
        val width: Double? = null,
        val height: Double? = null,
        val backgroundColor: String? = null,
        val buttonType: String? = null // 使用 String 类型接收，可以在使用时转换为枚举
    ) : NativeUnifiedChild()

    // 5. 应用图标
    data class AppIcon(
        override val x: Double? = null,
        override val y: Double? = null,
        val clickType: Int? = null,
        val clickIdType: Int? = null,
        val width: Double? = null,
        val height: Double? = null
    ) : NativeUnifiedChild()

    data class AdSourceLogo(
        override val x: Double? = null,
        override val y: Double? = null,
        val clickType: Int? = null,
        val clickIdType: Int? = null,
        val width: Double? = null,
        val height: Double? = null
    ) : NativeUnifiedChild()

    //5.1 下载六要素
    data class DownLoadInfo(
        override val x: Double? = null,
        override val y: Double? = null,
        val width: Double? = null,
        val fontSize: Double? = null,
        val fontColor: String? = null,
        val content: String? = null
    ) : NativeUnifiedChild()

    // 6. 视频
    data class Video(
        override val x: Double? = null,
        override val y: Double? = null,
        val clickType: Int? = null,
        val clickIdType: Int? = null,
        val width: Double? = null,
        val height: Double? = null
    ) : NativeUnifiedChild()
    // 6.1
    data class ShakeView(
        override val x: Double? = null,
        override val y: Double? = null,
        val width: Double? = null,
        val height: Double? = null
    ): NativeUnifiedChild()

    data class SlideView(
        override val x: Double? = null,
        override val y: Double? = null,
        val width: Double? = null,
        val height: Double? = null,
        val repeatCount: Int? = null
    ): NativeUnifiedChild()

    // 7. 关闭按钮
    data class CloseIcon(
        override val x: Double? = null,
        override val y: Double? = null,
        val clickType: Int? = null,
        val clickIdType: Int? = null,
        val imagePath: String? = null,
        val width: Double? = null,
        val height: Double? = null
    ) : NativeUnifiedChild()

    // 新增一个未知类型，用于处理未来可能增加的组件类型
    data class Unknown(
        override val x: Double? = null,
        override val y: Double? = null,
        val clickType: Int? = null,
        val clickIdType: Int? = null,
    ) : NativeUnifiedChild()
}


/**
 * 主解析类，负责解析从 Flutter 传递的整个视图树 Map
 * @param map 从 Flutter 端接收的原始 Map 数据
 */
class NativeUnifiedModule(map: Map<String, Any>?) : Serializable {
     var mainImageChild: NativeUnifiedChild.MainImage? = null
        private set
     var titleChild: NativeUnifiedChild.Title? = null
        private set
     var descriptionChild: NativeUnifiedChild.Description? = null
        private set
     var actionButtonChild: NativeUnifiedChild.ActionButton? = null
        private set
     var appIconChild: NativeUnifiedChild.AppIcon? = null
        private set
    var adSourceLogoChild: NativeUnifiedChild.AdSourceLogo? = null
        private set
    var downloadInfoChild: NativeUnifiedChild.DownLoadInfo? = null
        private set
     var videoChild: NativeUnifiedChild.Video? = null
        private set
     var shakeChild: NativeUnifiedChild.ShakeView? = null
        private set
    var slideChild: NativeUnifiedChild.SlideView? = null
        private set
     var closeIconChild: NativeUnifiedChild.CloseIcon? = null
        private set

    var height: Double? = null
    var backgroundColor: String? = null
    var initialized: Boolean = false
        private set

    init {
        // 在 init 块中调用解析方法
        parseModuleFromMap(map)
    }

    private fun parseModuleFromMap(map: Map<String, Any>?) {
        // 检查 map 是否有效
        if (map == null || map["type"] != "parent") {
            // 在 Android 端可以使用 Log 打印警告
            // Log.w("NativeUnifiedModule", "Invalid map provided. Expected type 'parent'.")
            return
        }

        initialized = true
        height = map["height"] as? Double
        backgroundColor = map["backgroundColor"] as? String

        // 获取 children 列表
        val childrenList = map["children"] as? List<*> ?: return
        childrenList.forEach { childData ->
            // 确保每个 child 都是一个 Map
            val childMap = childData as? Map<*, *> ?: return@forEach
            // 使用 when 语句根据 type 创建对应的 data class 实例
            when (childMap["type"] as? String) {
                "mainImage" -> mainImageChild = createMainImageChild(childMap)
                "mainTitle" -> titleChild = createTitleChild(childMap)
                "descText" -> descriptionChild = createDescriptionChild(childMap)
                "actionButton" -> actionButtonChild = createActionButtonChild(childMap)
                "appIcon" -> appIconChild = createAppIconChild(childMap)
                "adSourceLogo" -> adSourceLogoChild = createAdSourceLogoChild(childMap)
                "downloadInfo" -> downloadInfoChild = createDownloadInfoChild(childMap)
                "video" -> videoChild = createVideoChild(childMap)
                "shake" -> shakeChild = createShakeChild(childMap)
                "slide" -> slideChild = createSlideChild(childMap)
                "closeIcon" -> closeIconChild = createCloseIconChild(childMap)
                else -> {
                    Log.d("NativeUnifiedModule", "Unknown child type found")
                }
            }
        }
    }

    private fun Any?.asDouble(): Double? = this as? Double

    private fun Any?.asString(): String? = this as? String

    private fun Any?.asInt(): Int? = this as? Int

    private fun createMainImageChild(map: Map<*, *>): NativeUnifiedChild.MainImage {
        return NativeUnifiedChild.MainImage(
            x = map["x"].asDouble(),
            y = map["y"].asDouble(),
            clickType = map["clickType"].asInt(),
            clickIdType = map["clickIdType"].asInt(),
            width = map["width"].asDouble(),
            height = map["height"].asDouble(),
            backgroundColor = map["backgroundColor"].asString()
        )
    }

    private fun createTitleChild(map: Map<*, *>): NativeUnifiedChild.Title {
        return NativeUnifiedChild.Title(
            x = map["x"].asDouble(),
            y = map["y"].asDouble(),
            clickType = map["clickType"].asInt(),
            clickIdType = map["clickIdType"].asInt(),
            fontSize = map["fontSize"].asDouble(),
            color = map["color"].asString(),
            maxLines = map["maxLines"].asInt(),
            ellipsize = map["ellipsize"].asInt(),
        )
    }

    private fun createDescriptionChild(map: Map<*, *>): NativeUnifiedChild.Description {
        return NativeUnifiedChild.Description(
            x = map["x"].asDouble(),
            y = map["y"].asDouble(),
            clickType = map["clickType"].asInt(),
            clickIdType = map["clickIdType"].asInt(),
            fontSize = map["fontSize"].asDouble(),
            color = map["color"].asString(),
            width = map["width"].asDouble(),
            maxLines =  map["maxLines"].asInt(),
            ellipsize = map["ellipsize"].asInt(),
        )
    }

    private fun createActionButtonChild(map: Map<*, *>): NativeUnifiedChild.ActionButton {
        return NativeUnifiedChild.ActionButton(
            x = map["x"].asDouble(),
            y = map["y"].asDouble(),
            clickType = map["clickType"].asInt(),
            clickIdType = map["clickIdType"].asInt(),
            fontSize = map["fontSize"].asDouble(),
            fontColor = map["fontColor"].asString(),
            width = map["width"].asDouble(),
            height = map["height"].asDouble(),
            backgroundColor = map["backgroundColor"].asString(),
            buttonType = map["buttonType"].asString()
        )
    }

    /**
     * 创建应用图标（AppIcon）组件
     */
    private fun createAppIconChild(map: Map<*, *>): NativeUnifiedChild.AppIcon {
        return NativeUnifiedChild.AppIcon(
            x = map["x"].asDouble(),
            y = map["y"].asDouble(),
            clickType = map["clickType"].asInt(),
            clickIdType = map["clickIdType"].asInt(),
            width = map["width"].asDouble(),
            height = map["height"].asDouble()
        )
    }

    /**
     * 创建应用图标（AppIcon）组件
     */
    private fun createAdSourceLogoChild(map: Map<*, *>): NativeUnifiedChild.AdSourceLogo {
        return NativeUnifiedChild.AdSourceLogo(
            x = map["x"].asDouble(),
            y = map["y"].asDouble(),
            clickType = map["clickType"].asInt(),
            clickIdType = map["clickIdType"].asInt(),
            width = map["width"].asDouble(),
            height = map["height"].asDouble()
        )
    }

    private fun createDownloadInfoChild(map: Map<*, *>): NativeUnifiedChild.DownLoadInfo {
        return NativeUnifiedChild.DownLoadInfo(
            x = map["x"].asDouble(),
            y = map["y"].asDouble(),
            width = map["width"].asDouble(),
            fontSize = map["fontSize"].asDouble(),
            fontColor = map["fontColor"].asString(),
            content = map["content"].asString()
        )
    }

    /**
     * 创建视频（Video）组件
     */
    private fun createVideoChild(map: Map<*, *>): NativeUnifiedChild.Video {
        return NativeUnifiedChild.Video(
            x = map["x"].asDouble(),
            y = map["y"].asDouble(),
            // 视频区域也可能支持点击，所以解析 clickType
            clickType = map["clickType"].asInt(),
            clickIdType = map["clickIdType"].asInt(),
            width = map["width"].asDouble(),
            height = map["height"].asDouble()
        )
    }
    /**
     * 创建摇一摇组件
     */
    private fun createShakeChild(map: Map<*, *>): NativeUnifiedChild.ShakeView {
        return NativeUnifiedChild.ShakeView(
            x = map["x"].asDouble(),
            y = map["y"].asDouble(),
            width = map["width"].asDouble(),
            height = map["height"].asDouble()
        )
    }

    /**
     * 创建滑动组件
     */
    private fun createSlideChild(map: Map<*, *>): NativeUnifiedChild.SlideView {
        return NativeUnifiedChild.SlideView(
            x = map["x"].asDouble(),
            y = map["y"].asDouble(),
            width = map["width"].asDouble(),
            height = map["height"].asDouble(),
            repeatCount = map["repeatCount"].asInt()
        )
    }

    /**
     * 创建关闭按钮（CloseIcon）组件
     */
    private fun createCloseIconChild(map: Map<*, *>): NativeUnifiedChild.CloseIcon {
        return NativeUnifiedChild.CloseIcon(
            x = map["x"].asDouble(),
            y = map["y"].asDouble(),
            // 关闭按钮的 clickType 通常是固定的，但仍然从数据解析以保持灵活性
            clickType = map["clickType"].asInt(),
            clickIdType = map["clickIdType"].asInt(),
            imagePath = map["imagePath"].asString(),
            width = map["width"].asDouble(),
            height = map["height"].asDouble()
        )
    }
}
