import Foundation
import ObjectiveC

@_silgen_name("objc_msgSend") func sendPerformSelector(_:NSObject, _:Selector, _:Selector) -> AnyObject!;

let msgSend_block : @convention(block) (_: NSObject, _: Selector) -> AnyObject! = { (sself, aSelector) -> (AnyObject!) in
    return sendPerformSelector(sself, #selector(NSObjectProtocol.perform(_:)), aSelector)
}

let msgSend_IMP = imp_implementationWithBlock(unsafeBitCast(msgSend_block, to : AnyObject.self))
let method = class_getInstanceMethod(NSObject.self, #selector(NSObjectProtocol.perform(_:)))
let msgSend_old_IMP = method_setImplementation(method, msgSend_IMP)

func class_getSubclasses(parentClass: AnyClass) -> [AnyClass] {
    var numClasses = objc_getClassList(nil, 0)

    let classes = AutoreleasingUnsafeMutablePointer<AnyClass?>(UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(numClasses)))
    numClasses = objc_getClassList(classes, numClasses)

    var result = [AnyClass]()

    for i in 0..<numClasses {
        var superClass: AnyClass! = classes[Int(i)] as AnyClass!

        repeat {
            superClass = class_getSuperclass(superClass)
        } while (superClass != nil && NSStringFromClass(parentClass) != NSStringFromClass(superClass))

        if (superClass != nil) {
            result.append(classes[Int(i)]!)
        }
    }

    return result
}

func replaceMethod(type: AnyClass, selector: Selector, block: AnyObject!) {
    let myIMP = imp_implementationWithBlock(block)
    let method = class_getInstanceMethod(type, selector)
    method_setImplementation(method, myIMP)
}
