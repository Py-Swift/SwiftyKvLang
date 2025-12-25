#!/usr/bin/env python3
"""
Extract Kivy widget class information including properties and inheritance.
"""

import os
import re
from pathlib import Path
from typing import Dict, List, Tuple, Set

# Property types mapping
PROPERTY_TYPES = [
    'NumericProperty',
    'StringProperty', 
    'ObjectProperty',
    'BooleanProperty',
    'ListProperty',
    'DictProperty',
    'AliasProperty',
    'ReferenceListProperty',
    'OptionProperty',
    'ColorProperty',
    'BoundedNumericProperty',
    'VariableListProperty',
]

class WidgetInfo:
    def __init__(self, name: str, parent: str, properties: Dict[str, str]):
        self.name = name
        self.parent = parent
        self.properties = properties  # {property_name: property_type}

def extract_class_info(file_path: str) -> List[WidgetInfo]:
    """Extract class definitions and their properties from a Python file."""
    widgets = []
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find class definitions
    class_pattern = r'class\s+(\w+)\s*\(([^)]+)\)\s*:'
    class_matches = re.finditer(class_pattern, content)
    
    for match in class_matches:
        class_name = match.group(1)
        parent_class = match.group(2).strip()
        
        # Clean up parent class (remove multiple inheritance, keep first parent)
        if ',' in parent_class:
            parent_class = parent_class.split(',')[0].strip()
        
        # Find properties for this class
        properties = {}
        
        # Look for property definitions after the class definition
        class_start = match.end()
        # Find next class or end of file
        next_class = re.search(r'\nclass\s+\w+\s*\(', content[class_start:])
        if next_class:
            class_end = class_start + next_class.start()
        else:
            class_end = len(content)
        
        class_body = content[class_start:class_end]
        
        # Find property definitions
        for prop_type in PROPERTY_TYPES:
            # Pattern: property_name = PropertyType(...)
            pattern = rf'^\s+(\w+)\s*=\s*{prop_type}\s*\('
            prop_matches = re.finditer(pattern, class_body, re.MULTILINE)
            
            for prop_match in prop_matches:
                prop_name = prop_match.group(1)
                properties[prop_name] = prop_type
        
        widgets.append(WidgetInfo(class_name, parent_class, properties))
    
    return widgets

def process_uix_directory(uix_path: str) -> Dict[str, WidgetInfo]:
    """Process all Python files in the uix directory."""
    all_widgets = {}
    
    uix_dir = Path(uix_path)
    for py_file in uix_dir.glob('*.py'):
        if py_file.name.startswith('__'):
            continue
        
        try:
            widgets = extract_class_info(str(py_file))
            for widget in widgets:
                # Only include public classes (not starting with _)
                if not widget.name.startswith('_'):
                    all_widgets[widget.name] = widget
        except Exception as e:
            print(f"Error processing {py_file}: {e}")
    
    return all_widgets

def build_inheritance_hierarchy(widgets: Dict[str, WidgetInfo]) -> Dict[str, List[str]]:
    """Build a map of widget -> list of all parent widgets."""
    hierarchy = {}
    
    def get_parents(widget_name: str, visited: Set[str] = None) -> List[str]:
        if visited is None:
            visited = set()
        
        if widget_name in visited:
            return []
        
        visited.add(widget_name)
        
        if widget_name not in widgets:
            return []
        
        widget = widgets[widget_name]
        parents = [widget.parent]
        
        # Recursively get parent's parents
        parent_parents = get_parents(widget.parent, visited)
        parents.extend(parent_parents)
        
        return parents
    
    for widget_name in widgets:
        hierarchy[widget_name] = get_parents(widget_name)
    
    return hierarchy

def get_all_properties(widget_name: str, widgets: Dict[str, WidgetInfo], 
                       hierarchy: Dict[str, List[str]]) -> Dict[str, str]:
    """Get all properties for a widget including inherited ones."""
    all_props = {}
    
    # Add properties from parents (in reverse order so child overrides parent)
    if widget_name in hierarchy:
        for parent in reversed(hierarchy[widget_name]):
            if parent in widgets:
                all_props.update(widgets[parent].properties)
    
    # Add widget's own properties (overrides parent properties)
    if widget_name in widgets:
        all_props.update(widgets[widget_name].properties)
    
    return all_props

def generate_swift_file(widgets: Dict[str, WidgetInfo], hierarchy: Dict[str, List[str]]) -> str:
    """Generate Swift source code for the widget registry."""
    
    swift_code = """// KivyWidgetRegistry.swift
// Auto-generated from Kivy widget definitions
//
// This file contains information about Kivy widgets including their
// properties and inheritance hierarchy.

import Foundation

/// Represents a single Kivy property with its name and type
public struct KivyPropertyInfo: Equatable, Hashable {
    public let name: String
    public let type: String
    
    public init(name: String, type: String) {
        self.name = name
        self.type = type
    }
}

/// Represents a Kivy widget with its parent class and properties
public struct KivyWidgetInfo {
    public let widgetName: String
    public let parentClass: String?
    public let directProperties: Set<KivyPropertyInfo>
    
    public init(widgetName: String, parentClass: String?, directProperties: Set<KivyPropertyInfo>) {
        self.widgetName = widgetName
        self.parentClass = parentClass
        self.directProperties = directProperties
    }
}

/// Registry of all Kivy widgets with methods to query widget information
public class KivyWidgetRegistry {
    
    /// Dictionary mapping widget names to their information
    private static let widgetRegistry: [String: KivyWidgetInfo] = [
"""
    
    # Sort widgets alphabetically for consistent output
    sorted_widgets = sorted(widgets.items(), key=lambda x: x[0])
    
    for widget_name, widget_info in sorted_widgets:
        # Only include widgets with properties or that are commonly used
        if len(widget_info.properties) == 0 and widget_name not in [
            'Widget', 'Layout', 'FloatLayout', 'BoxLayout', 'GridLayout',
            'AnchorLayout', 'RelativeLayout', 'StackLayout', 'PageLayout',
            'ScatterLayout', 'Button', 'Label', 'Image', 'TextInput'
        ]:
            continue
        
        parent = f'"{widget_info.parent}"' if widget_info.parent else 'nil'
        
        swift_code += f'        "{widget_name}": KivyWidgetInfo(\n'
        swift_code += f'            widgetName: "{widget_name}",\n'
        swift_code += f'            parentClass: {parent},\n'
        swift_code += f'            directProperties: [\n'
        
        # Sort properties alphabetically
        sorted_props = sorted(widget_info.properties.items())
        for prop_name, prop_type in sorted_props:
            swift_code += f'                KivyPropertyInfo(name: "{prop_name}", type: "{prop_type}"),\n'
        
        swift_code += f'            ]\n'
        swift_code += f'        ),\n'
    
    swift_code += """    ]
    
    /// Get widget information by name
    /// - Parameter widgetName: Name of the widget (e.g., "Button", "Label")
    /// - Returns: Widget information if found, nil otherwise
    public static func getWidgetInfo(_ widgetName: String) -> KivyWidgetInfo? {
        return widgetRegistry[widgetName]
    }
    
    /// Get all properties for a widget including inherited properties
    /// - Parameter widgetName: Name of the widget
    /// - Returns: Set of all properties (direct + inherited)
    public static func getAllProperties(for widgetName: String) -> Set<KivyPropertyInfo> {
        var allProperties = Set<KivyPropertyInfo>()
        
        // Recursively collect properties from parent classes
        func collectProperties(from widget: String) {
            guard let info = widgetRegistry[widget] else { return }
            
            // Add this widget's properties
            allProperties.formUnion(info.directProperties)
            
            // Recursively add parent's properties
            if let parent = info.parentClass {
                collectProperties(from: parent)
            }
        }
        
        collectProperties(from: widgetName)
        return allProperties
    }
    
    /// Check if a property exists on a widget (including inherited properties)
    /// - Parameters:
    ///   - propertyName: Name of the property
    ///   - widgetName: Name of the widget
    /// - Returns: true if the property exists on the widget or its parents
    public static func hasProperty(_ propertyName: String, on widgetName: String) -> Bool {
        let allProps = getAllProperties(for: widgetName)
        return allProps.contains { $0.name == propertyName }
    }
    
    /// Get the type of a property on a widget
    /// - Parameters:
    ///   - propertyName: Name of the property
    ///   - widgetName: Name of the widget
    /// - Returns: Property type if found, nil otherwise
    public static func getPropertyType(_ propertyName: String, on widgetName: String) -> String? {
        let allProps = getAllProperties(for: widgetName)
        return allProps.first { $0.name == propertyName }?.type
    }
    
    /// Get all registered widget names
    /// - Returns: Array of all widget names
    public static func getAllWidgetNames() -> [String] {
        return Array(widgetRegistry.keys).sorted()
    }
    
    /// Check if a widget exists in the registry
    /// - Parameter widgetName: Name of the widget
    /// - Returns: true if the widget is registered
    public static func widgetExists(_ widgetName: String) -> Bool {
        return widgetRegistry[widgetName] != nil
    }
}
"""
    
    return swift_code

def main():
    # Path to Kivy uix directory
    uix_path = '/Volumes/CodeSSD/GitHub/SwiftyKvLang/kivy/kivy/uix'
    
    print("Extracting widget information from Kivy source files...")
    widgets = process_uix_directory(uix_path)
    print(f"Found {len(widgets)} widget classes")
    
    print("Building inheritance hierarchy...")
    hierarchy = build_inheritance_hierarchy(widgets)
    
    print("Generating Swift source file...")
    swift_code = generate_swift_file(widgets, hierarchy)
    
    output_path = '/Volumes/CodeSSD/GitHub/SwiftyKvLang/KvToPyClass/Sources/KvToPyClass/KivyWidgetRegistry.swift'
    with open(output_path, 'w') as f:
        f.write(swift_code)
    
    print(f"Successfully generated {output_path}")
    
    # Print some statistics
    print(f"\nStatistics:")
    print(f"  Total widgets: {len(widgets)}")
    print(f"  Widgets with properties: {sum(1 for w in widgets.values() if w.properties)}")
    
    # Show some examples
    print(f"\nExample widgets:")
    for name in ['Widget', 'Button', 'Label', 'BoxLayout', 'TextInput']:
        if name in widgets:
            widget = widgets[name]
            all_props = get_all_properties(name, widgets, hierarchy)
            print(f"  {name}: {len(widget.properties)} direct properties, {len(all_props)} total properties")

if __name__ == '__main__':
    main()
