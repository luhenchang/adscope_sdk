package xyz.adscope.adscope_sdk.data


// --- SplashBottomModule and related classes ---
enum class ChildType(val typeName: String) {
    IMAGE("image"),
    TEXT("text");

    companion object {
        fun fromTypeName(name: String?): ChildType? {
            return entries.find { it.typeName == name }
        }
    }
}

open class SplashBottomBaseChild(
    open val x: Double? = null,
    open val y: Double? = null
)

data class SplashBottomImageChild(
    val width: Double? = null,
    val height: Double? = null,
    val imagePath: String? = null,
    override val x: Double? = null,
    override val y: Double? = null
) : SplashBottomBaseChild(x, y)

data class SplashBottomTextChild(
    val fontSize: Double? = null,
    val color: String? = null,
    val text: String? = null,
    override val x: Double? = null,
    override val y: Double? = null
) : SplashBottomBaseChild(x, y)

data class SplashBottomModule(
    val imgChildren: SplashBottomImageChild? = null,
    val textChildren: SplashBottomTextChild? = null,
    val height: Double = 0.0,
    val backgroundColor: String = "#00000000",
    val initialized: Boolean = false
) {
    companion object {
        // This is a static-like property in Kotlin, accessible via SplashBottomModule.current
        var current: SplashBottomModule? = null // To hold the latest parsed module

        @Suppress("UNCHECKED_CAST")
        fun fromMap(map: Map<String, Any>?): SplashBottomModule? {
            if (map == null) {
                println("SplashBottomModule.fromMap: Input map is null, returning default.")
                return null
            }

            if (map["type"] != "parent") {
                println("SplashBottomModule.fromMap: Invalid map structure. Expected type 'parent', but got ${map["type"]}. Proceeding with caution.")
                // Decide if you want to return default or try parsing what's available
                return  null
            }

            val moduleHeight = (map["height"] as? Number)?.toDouble() ?: 0.0
            val moduleBackgroundColor = map["backgroundColor"] as? String ?: "#00000000"
            var imageChild: SplashBottomImageChild? = null
            var textChild: SplashBottomTextChild? = null
            var isInitialized = false

            val childrenList = map["children"] as? List<*>
            if (childrenList != null) {
                isInitialized = true
                for (childUnknownType in childrenList) {
                    if (childUnknownType !is Map<*, *>) continue
                    val childMap = childUnknownType as? Map<String, Any> ?: continue
                    when (ChildType.fromTypeName(childMap["type"] as? String)) {
                        ChildType.IMAGE -> imageChild = createImageChild(childMap)
                        ChildType.TEXT -> textChild = createTextChild(childMap)
                        null -> println("SplashBottomModule.fromMap: Unknown child type: ${childMap["type"]}")
                    }
                }
            } else {
                if (map["type"] == "parent") { // Considered initialized if parent type and attributes are present
                    isInitialized = true
                }
            }
            return SplashBottomModule(
                imgChildren = imageChild,
                textChildren = textChild,
                height = moduleHeight,
                backgroundColor = moduleBackgroundColor,
                initialized = isInitialized
            ).also { current = it }
        }

        private fun createImageChild(map: Map<String, Any>): SplashBottomImageChild {
            return SplashBottomImageChild(
                width = (map["width"] as? Number)?.toDouble(),
                height = (map["height"] as? Number)?.toDouble(),
                x = (map["x"] as? Number)?.toDouble(),
                y = (map["y"] as? Number)?.toDouble(),
                imagePath = map["imagePath"] as? String
            )
        }

        private fun createTextChild(map: Map<String, Any>): SplashBottomTextChild {
            return SplashBottomTextChild(
                fontSize = (map["fontSize"] as? Number)?.toDouble(),
                color = map["color"] as? String,
                x = (map["x"] as? Number)?.toDouble(),
                y = (map["y"] as? Number)?.toDouble(),
                text = map["text"] as? String
            )
        }
    }
}