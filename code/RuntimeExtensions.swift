import Foundation
import ObjectiveC

@asmname("objc_msgSend") func sendPerformSelector(_:NSObject, _:Selector, _:Selector) -> AnyObject!;

let msgSend_block : @convention(block) (sself: NSObject, aSelector: Selector) -> AnyObject! = { (sself, aSelector) -> (AnyObject!) in
    return sendPerformSelector(sself, "performSelector:", aSelector)
}

let msgSend_IMP = imp_implementationWithBlock(unsafeBitCast(msgSend_block, AnyObject.self))
let method = class_getInstanceMethod(NSObject.self, "performSelector:")
let msgSend_old_IMP = method_setImplementation(method, msgSend_IMP)

func class_getSubclasses(parentClass: AnyClass) -> [AnyClass] {
    var numClasses = objc_getClassList(nil, 0)

    var classes = AutoreleasingUnsafeMutablePointer<AnyClass?>(malloc(Int(sizeof(AnyClass) * Int(numClasses))))
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
