/// Selector for matching widgets to rules
///
/// KV selectors determine which widgets a rule applies to:
/// - name: Match by widget type (e.g., <Button>)
/// - className: Match by CSS-style class (e.g., <.myClass>)
/// - multiple: Multiple selectors (e.g., <Button,Label>)
/// - dynamicClass: Create new class from base(s) (e.g., <New@Base> or <New@Base1+Base2>)
///
/// Reference: parser.py lines 394-432 (_build_rule method)
public enum KvSelector: Sendable, Equatable {
    /// Match by widget type name: <WidgetName>
    case name(String)
    
    /// Match by CSS-style class: <.className>
    case className(String)
    
    /// Multiple selectors: <Widget1,Widget2,Widget3>
    case multiple([KvSelector])
    
    /// Dynamic class creation: <NewClass@BaseClass> or <NewClass@Base1+Base2>
    case dynamicClass(name: String, bases: [String])
    
    /// Returns the primary name for this selector (for display/debugging)
    public var primaryName: String {
        switch self {
        case .name(let n): return n
        case .className(let n): return ".\(n)"
        case .multiple(let selectors): 
            return selectors.map { $0.primaryName }.joined(separator: ",")
        case .dynamicClass(let name, let bases):
            return "\(name)@\(bases.joined(separator: "+"))"
        }
    }
}

extension KvSelector: CustomStringConvertible {
    public var description: String {
        return "<\(primaryName)>"
    }
}
