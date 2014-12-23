import Foundation
import ObjectiveC

@asmname("objc_msgSend") func sendPerformSelector(NSObject, Selector, Selector) -> Void;

extension NSObject {
    public func performSelector(selector : Selector) -> Void {
        return sendPerformSelector(self, "performSelector:", selector)
    }
}

func class_getSubclasses(parentClass: AnyClass) -> [AnyClass] {
    var numClasses = objc_getClassList(nil, 0)

    var classes = AutoreleasingUnsafeMutablePointer<AnyClass?>(malloc(UInt(sizeof(AnyClass) * Int(numClasses))))
    numClasses = objc_getClassList(classes, numClasses)

    var result = [AnyClass]()

    for i in 0..<numClasses {
        var superClass: AnyClass! = classes[Int(i)] as AnyClass!

        do {
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
