import SceneKit
#if canImport(UIKit)
import UIKit
typealias PlatformColor = UIColor
typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
typealias PlatformColor = NSColor
typealias PlatformImage = NSImage
#endif

class MaterialBuilder {
    static func buildLiquidGlassMaterial(color: PlatformColor) -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .blinn
        
        material.diffuse.contents = color.withAlphaComponent(0.8)
        material.specular.contents = PlatformColor.white
        material.shininess = 0.95
        
        material.transparencyMode = .dualLayer
        material.isDoubleSided = true
        material.transparency = 0.8
        
        if let normalImage = PlatformImage(named: "WaterNormalMap") {
            material.normal.contents = normalImage
            material.normal.intensity = 0.5
        }
        
        return material
    }
    
    static func adjustLiquidColor(material: SCNMaterial?, baseColor: PlatformColor, damping: CGFloat) {
        guard let material = material else { return }
        
        // Damping ranges approx 0.1 to 0.95.
        // Fast (low damping) = Lighter color (more alpha)
        // Slow (high damping) = Darker color (more opaque)
        
        let normalizedDamping = max(0.0, min((damping - 0.1) / 0.85, 1.0))
        
        // Start alpha at 0.5 for fast balls, increase up to 0.95 for slow balls.
        let targetAlpha = 0.5 + (normalizedDamping * 0.45)
        
        // Slightly dim the base color if it's highly viscous by blending with black, 
        // to make the change strictly "lighter vs darker".
        #if canImport(UIKit)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        baseColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        // Reduce brightness slightly when viscous
        let adjustedBrightness = max(0.5, b - (normalizedDamping * 0.3))
        let newColor = UIColor(hue: h, saturation: s, brightness: adjustedBrightness, alpha: targetAlpha)
        #elseif canImport(AppKit)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        baseColor.usingColorSpace(.deviceRGB)?.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        let adjustedBrightness = max(0.5, b - (normalizedDamping * 0.3))
        let newColor = NSColor(deviceHue: h, saturation: s, brightness: adjustedBrightness, alpha: targetAlpha)
        #endif
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.2
        material.diffuse.contents = newColor
        SCNTransaction.commit()
    }
    
    static func buildWallMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .lambert
        material.diffuse.contents = PlatformColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0) // Rich golden yellow
        return material
    }
    
    static func buildFloorMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .lambert
        material.diffuse.contents = PlatformColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0) // Rich golden yellow
        return material
    }
    
    static func buildTargetMaterial(color: PlatformColor) -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .blinn
        
        #if canImport(UIKit)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        let darkenedColor = UIColor(hue: h, saturation: s, brightness: max(0, b - 0.3), alpha: a)
        #elseif canImport(AppKit)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.usingColorSpace(.deviceRGB)?.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        let darkenedColor = NSColor(deviceHue: h, saturation: s, brightness: max(0, b - 0.3), alpha: a)
        #endif
        
        material.diffuse.contents = darkenedColor.withAlphaComponent(0.6)
        material.emission.contents = darkenedColor
        material.transparencyMode = .dualLayer
        material.transparency = 0.8
        return material
    }
}
