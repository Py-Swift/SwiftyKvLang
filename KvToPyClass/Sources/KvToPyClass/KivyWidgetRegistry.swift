// KivyWidgetRegistry.swift
// Auto-generated from Kivy widget definitions
//
// This file contains information about Kivy widgets including their
// properties and inheritance hierarchy.

import Foundation

/// Kivy property types
public enum KivyPropertyType: String, Equatable, Hashable {
    case numericProperty = "NumericProperty"
    case stringProperty = "StringProperty"
    case listProperty = "ListProperty"
    case objectProperty = "ObjectProperty"
    case booleanProperty = "BooleanProperty"
    case dictProperty = "DictProperty"
    case optionProperty = "OptionProperty"
    case referenceListProperty = "ReferenceListProperty"
    case aliasProperty = "AliasProperty"
    case boundedNumericProperty = "BoundedNumericProperty"
    case variableListProperty = "VariableListProperty"
    case colorProperty = "ColorProperty"
}

/// Represents a single Kivy property with its name and type
public struct KivyPropertyInfo: Equatable, Hashable {
    public let name: String
    public let type: KivyPropertyType
    
    public init(name: String, type: KivyPropertyType) {
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
        "Accordion": KivyWidgetInfo(
            widgetName: "Accordion",
            parentClass: "Widget",
            directProperties: [
                KivyPropertyInfo(name: "anim_duration", type: .numericProperty),
                KivyPropertyInfo(name: "anim_func", type: .objectProperty),
                KivyPropertyInfo(name: "min_space", type: .numericProperty),
                KivyPropertyInfo(name: "orientation", type: .optionProperty),
            ]
        ),
        "AccordionItem": KivyWidgetInfo(
            widgetName: "AccordionItem",
            parentClass: "FloatLayout",
            directProperties: [
                KivyPropertyInfo(name: "accordion", type: .objectProperty),
                KivyPropertyInfo(name: "background_disabled_normal", type: .stringProperty),
                KivyPropertyInfo(name: "background_disabled_selected", type: .stringProperty),
                KivyPropertyInfo(name: "background_normal", type: .stringProperty),
                KivyPropertyInfo(name: "background_selected", type: .stringProperty),
                KivyPropertyInfo(name: "collapse", type: .booleanProperty),
                KivyPropertyInfo(name: "collapse_alpha", type: .numericProperty),
                KivyPropertyInfo(name: "container", type: .objectProperty),
                KivyPropertyInfo(name: "container_title", type: .objectProperty),
                KivyPropertyInfo(name: "content_size", type: .listProperty),
                KivyPropertyInfo(name: "min_space", type: .numericProperty),
                KivyPropertyInfo(name: "orientation", type: .optionProperty),
                KivyPropertyInfo(name: "title", type: .stringProperty),
                KivyPropertyInfo(name: "title_args", type: .dictProperty),
                KivyPropertyInfo(name: "title_template", type: .stringProperty),
            ]
        ),
        "ActionBar": KivyWidgetInfo(
            widgetName: "ActionBar",
            parentClass: "BoxLayout",
            directProperties: [
                KivyPropertyInfo(name: "action_view", type: .objectProperty),
                KivyPropertyInfo(name: "background_color", type: .colorProperty),
                KivyPropertyInfo(name: "background_image", type: .stringProperty),
                KivyPropertyInfo(name: "border", type: .listProperty),
            ]
        ),
        "ActionButton": KivyWidgetInfo(
            widgetName: "ActionButton",
            parentClass: "Button",
            directProperties: [
                KivyPropertyInfo(name: "icon", type: .stringProperty),
            ]
        ),
        "ActionGroup": KivyWidgetInfo(
            widgetName: "ActionGroup",
            parentClass: "ActionItem",
            directProperties: [
                KivyPropertyInfo(name: "dropdown_width", type: .numericProperty),
                KivyPropertyInfo(name: "is_open", type: .booleanProperty),
                KivyPropertyInfo(name: "mode", type: .optionProperty),
                KivyPropertyInfo(name: "separator_image", type: .stringProperty),
                KivyPropertyInfo(name: "separator_width", type: .numericProperty),
                KivyPropertyInfo(name: "use_separator", type: .booleanProperty),
            ]
        ),
        "ActionItem": KivyWidgetInfo(
            widgetName: "ActionItem",
            parentClass: "object",
            directProperties: [
                KivyPropertyInfo(name: "background_down", type: .stringProperty),
                KivyPropertyInfo(name: "background_normal", type: .stringProperty),
                KivyPropertyInfo(name: "important", type: .booleanProperty),
                KivyPropertyInfo(name: "inside_group", type: .booleanProperty),
                KivyPropertyInfo(name: "minimum_width", type: .numericProperty),
                KivyPropertyInfo(name: "mipmap", type: .booleanProperty),
                KivyPropertyInfo(name: "pack_width", type: .aliasProperty),
            ]
        ),
        "ActionOverflow": KivyWidgetInfo(
            widgetName: "ActionOverflow",
            parentClass: "ActionGroup",
            directProperties: [
                KivyPropertyInfo(name: "overflow_image", type: .stringProperty),
            ]
        ),
        "ActionPrevious": KivyWidgetInfo(
            widgetName: "ActionPrevious",
            parentClass: "BoxLayout",
            directProperties: [
                KivyPropertyInfo(name: "app_icon", type: .stringProperty),
                KivyPropertyInfo(name: "app_icon_height", type: .numericProperty),
                KivyPropertyInfo(name: "app_icon_width", type: .numericProperty),
                KivyPropertyInfo(name: "color", type: .colorProperty),
                KivyPropertyInfo(name: "markup", type: .booleanProperty),
                KivyPropertyInfo(name: "previous_image", type: .stringProperty),
                KivyPropertyInfo(name: "previous_image_height", type: .numericProperty),
                KivyPropertyInfo(name: "previous_image_width", type: .numericProperty),
                KivyPropertyInfo(name: "title", type: .stringProperty),
                KivyPropertyInfo(name: "with_previous", type: .booleanProperty),
            ]
        ),
        "ActionSeparator": KivyWidgetInfo(
            widgetName: "ActionSeparator",
            parentClass: "ActionItem",
            directProperties: [
                KivyPropertyInfo(name: "background_image", type: .stringProperty),
            ]
        ),
        "ActionToggleButton": KivyWidgetInfo(
            widgetName: "ActionToggleButton",
            parentClass: "ActionItem",
            directProperties: [
                KivyPropertyInfo(name: "icon", type: .stringProperty),
            ]
        ),
        "ActionView": KivyWidgetInfo(
            widgetName: "ActionView",
            parentClass: "BoxLayout",
            directProperties: [
                KivyPropertyInfo(name: "action_previous", type: .objectProperty),
                KivyPropertyInfo(name: "background_color", type: .colorProperty),
                KivyPropertyInfo(name: "background_image", type: .stringProperty),
                KivyPropertyInfo(name: "overflow_group", type: .objectProperty),
                KivyPropertyInfo(name: "use_separator", type: .booleanProperty),
            ]
        ),
        "AdvancedEffectBase": KivyWidgetInfo(
            widgetName: "AdvancedEffectBase",
            parentClass: "EffectBase",
            directProperties: [
                KivyPropertyInfo(name: "uniforms", type: .dictProperty),
            ]
        ),
        "AnchorLayout": KivyWidgetInfo(
            widgetName: "AnchorLayout",
            parentClass: "Layout",
            directProperties: [
                KivyPropertyInfo(name: "anchor_x", type: .optionProperty),
                KivyPropertyInfo(name: "anchor_y", type: .optionProperty),
                KivyPropertyInfo(name: "padding", type: .variableListProperty),
            ]
        ),
        "BoxLayout": KivyWidgetInfo(
            widgetName: "BoxLayout",
            parentClass: "Layout",
            directProperties: [
                KivyPropertyInfo(name: "minimum_height", type: .numericProperty),
                KivyPropertyInfo(name: "minimum_size", type: .referenceListProperty),
                KivyPropertyInfo(name: "minimum_width", type: .numericProperty),
                KivyPropertyInfo(name: "orientation", type: .optionProperty),
                KivyPropertyInfo(name: "padding", type: .variableListProperty),
                KivyPropertyInfo(name: "spacing", type: .numericProperty),
            ]
        ),
        "Bubble": KivyWidgetInfo(
            widgetName: "Bubble",
            parentClass: "BoxLayout",
            directProperties: [
                KivyPropertyInfo(name: "arrow_color", type: .colorProperty),
                KivyPropertyInfo(name: "arrow_image", type: .stringProperty),
                KivyPropertyInfo(name: "arrow_margin", type: .referenceListProperty),
                KivyPropertyInfo(name: "arrow_margin_x", type: .numericProperty),
                KivyPropertyInfo(name: "arrow_margin_y", type: .numericProperty),
                KivyPropertyInfo(name: "arrow_pos", type: .optionProperty),
                KivyPropertyInfo(name: "content", type: .objectProperty),
                KivyPropertyInfo(name: "content_height", type: .numericProperty),
                KivyPropertyInfo(name: "content_size", type: .referenceListProperty),
                KivyPropertyInfo(name: "content_width", type: .numericProperty),
                KivyPropertyInfo(name: "flex_arrow_pos", type: .listProperty),
                KivyPropertyInfo(name: "limit_to", type: .objectProperty),
                KivyPropertyInfo(name: "show_arrow", type: .booleanProperty),
            ]
        ),
        "BubbleContent": KivyWidgetInfo(
            widgetName: "BubbleContent",
            parentClass: "BoxLayout",
            directProperties: [
                KivyPropertyInfo(name: "background_color", type: .colorProperty),
                KivyPropertyInfo(name: "background_image", type: .stringProperty),
                KivyPropertyInfo(name: "border", type: .listProperty),
                KivyPropertyInfo(name: "border_auto_scale", type: .optionProperty),
            ]
        ),
        "Button": KivyWidgetInfo(
            widgetName: "Button",
            parentClass: "ButtonBehavior",
            directProperties: [
                KivyPropertyInfo(name: "background_color", type: .colorProperty),
                KivyPropertyInfo(name: "background_disabled_down", type: .stringProperty),
                KivyPropertyInfo(name: "background_disabled_normal", type: .stringProperty),
                KivyPropertyInfo(name: "background_down", type: .stringProperty),
                KivyPropertyInfo(name: "background_normal", type: .stringProperty),
                KivyPropertyInfo(name: "border", type: .listProperty),
            ]
        ),
        "Camera": KivyWidgetInfo(
            widgetName: "Camera",
            parentClass: "Image",
            directProperties: [
                KivyPropertyInfo(name: "index", type: .numericProperty),
                KivyPropertyInfo(name: "play", type: .booleanProperty),
                KivyPropertyInfo(name: "resolution", type: .listProperty),
            ]
        ),
        "CardTransition": KivyWidgetInfo(
            widgetName: "CardTransition",
            parentClass: "SlideTransition",
            directProperties: [
                KivyPropertyInfo(name: "mode", type: .optionProperty),
            ]
        ),
        "Carousel": KivyWidgetInfo(
            widgetName: "Carousel",
            parentClass: "StencilView",
            directProperties: [
                KivyPropertyInfo(name: "_current", type: .objectProperty),
                KivyPropertyInfo(name: "_index", type: .numericProperty),
                KivyPropertyInfo(name: "_next", type: .objectProperty),
                KivyPropertyInfo(name: "_offset", type: .numericProperty),
                KivyPropertyInfo(name: "_prev", type: .objectProperty),
                KivyPropertyInfo(name: "_touch", type: .objectProperty),
                KivyPropertyInfo(name: "anim_cancel_duration", type: .numericProperty),
                KivyPropertyInfo(name: "anim_move_duration", type: .numericProperty),
                KivyPropertyInfo(name: "anim_type", type: .stringProperty),
                KivyPropertyInfo(name: "current_slide", type: .aliasProperty),
                KivyPropertyInfo(name: "direction", type: .optionProperty),
                KivyPropertyInfo(name: "ignore_perpendicular_swipes", type: .booleanProperty),
                KivyPropertyInfo(name: "index", type: .aliasProperty),
                KivyPropertyInfo(name: "loop", type: .booleanProperty),
                KivyPropertyInfo(name: "min_move", type: .numericProperty),
                KivyPropertyInfo(name: "next_slide", type: .aliasProperty),
                KivyPropertyInfo(name: "previous_slide", type: .aliasProperty),
                KivyPropertyInfo(name: "scroll_distance", type: .numericProperty),
                KivyPropertyInfo(name: "scroll_timeout", type: .numericProperty),
                KivyPropertyInfo(name: "slides", type: .listProperty),
                KivyPropertyInfo(name: "slides_container", type: .aliasProperty),
            ]
        ),
        "ChannelMixEffect": KivyWidgetInfo(
            widgetName: "ChannelMixEffect",
            parentClass: "EffectBase",
            directProperties: [
                KivyPropertyInfo(name: "order", type: .listProperty),
            ]
        ),
        "CheckBox": KivyWidgetInfo(
            widgetName: "CheckBox",
            parentClass: "ToggleButtonBehavior",
            directProperties: [
                KivyPropertyInfo(name: "background_checkbox_disabled_down", type: .stringProperty),
                KivyPropertyInfo(name: "background_checkbox_disabled_normal", type: .stringProperty),
                KivyPropertyInfo(name: "background_checkbox_down", type: .stringProperty),
                KivyPropertyInfo(name: "background_checkbox_normal", type: .stringProperty),
                KivyPropertyInfo(name: "background_radio_disabled_down", type: .stringProperty),
                KivyPropertyInfo(name: "background_radio_disabled_normal", type: .stringProperty),
                KivyPropertyInfo(name: "background_radio_down", type: .stringProperty),
                KivyPropertyInfo(name: "background_radio_normal", type: .stringProperty),
                KivyPropertyInfo(name: "color", type: .colorProperty),
            ]
        ),
        "CodeInput": KivyWidgetInfo(
            widgetName: "CodeInput",
            parentClass: "CodeNavigationBehavior",
            directProperties: [
                KivyPropertyInfo(name: "lexer", type: .objectProperty),
                KivyPropertyInfo(name: "style", type: .objectProperty),
                KivyPropertyInfo(name: "style_name", type: .optionProperty),
            ]
        ),
        "ColorPicker": KivyWidgetInfo(
            widgetName: "ColorPicker",
            parentClass: "RelativeLayout",
            directProperties: [
                KivyPropertyInfo(name: "color", type: .listProperty),
                KivyPropertyInfo(name: "font_name", type: .stringProperty),
                KivyPropertyInfo(name: "foreground_color", type: .listProperty),
                KivyPropertyInfo(name: "hex_color", type: .aliasProperty),
                KivyPropertyInfo(name: "hsv", type: .aliasProperty),
                KivyPropertyInfo(name: "wheel", type: .objectProperty),
            ]
        ),
        "ColorWheel": KivyWidgetInfo(
            widgetName: "ColorWheel",
            parentClass: "Widget",
            directProperties: [
                KivyPropertyInfo(name: "_origin", type: .listProperty),
                KivyPropertyInfo(name: "_piece_divisions", type: .numericProperty),
                KivyPropertyInfo(name: "_pieces_of_pie", type: .numericProperty),
                KivyPropertyInfo(name: "_radius", type: .numericProperty),
                KivyPropertyInfo(name: "a", type: .boundedNumericProperty),
                KivyPropertyInfo(name: "b", type: .boundedNumericProperty),
                KivyPropertyInfo(name: "color", type: .referenceListProperty),
                KivyPropertyInfo(name: "g", type: .boundedNumericProperty),
                KivyPropertyInfo(name: "r", type: .boundedNumericProperty),
            ]
        ),
        "ContentPanel": KivyWidgetInfo(
            widgetName: "ContentPanel",
            parentClass: "ScrollView",
            directProperties: [
                KivyPropertyInfo(name: "container", type: .objectProperty),
                KivyPropertyInfo(name: "current_panel", type: .objectProperty),
                KivyPropertyInfo(name: "current_uid", type: .numericProperty),
                KivyPropertyInfo(name: "panels", type: .dictProperty),
            ]
        ),
        "DropDown": KivyWidgetInfo(
            widgetName: "DropDown",
            parentClass: "ScrollView",
            directProperties: [
                KivyPropertyInfo(name: "attach_to", type: .objectProperty),
                KivyPropertyInfo(name: "auto_dismiss", type: .booleanProperty),
                KivyPropertyInfo(name: "auto_width", type: .booleanProperty),
                KivyPropertyInfo(name: "container", type: .objectProperty),
                KivyPropertyInfo(name: "dismiss_on_select", type: .booleanProperty),
                KivyPropertyInfo(name: "max_height", type: .numericProperty),
                KivyPropertyInfo(name: "min_state_time", type: .numericProperty),
            ]
        ),
        "EffectBase": KivyWidgetInfo(
            widgetName: "EffectBase",
            parentClass: "EventDispatcher",
            directProperties: [
                KivyPropertyInfo(name: "fbo", type: .objectProperty),
                KivyPropertyInfo(name: "glsl", type: .stringProperty),
                KivyPropertyInfo(name: "source", type: .stringProperty),
            ]
        ),
        "EffectWidget": KivyWidgetInfo(
            widgetName: "EffectWidget",
            parentClass: "RelativeLayout",
            directProperties: [
                KivyPropertyInfo(name: "_bound_effects", type: .listProperty),
                KivyPropertyInfo(name: "background_color", type: .listProperty),
                KivyPropertyInfo(name: "effects", type: .listProperty),
                KivyPropertyInfo(name: "fbo_list", type: .listProperty),
                KivyPropertyInfo(name: "texture", type: .objectProperty),
            ]
        ),
        "FadeTransition": KivyWidgetInfo(
            widgetName: "FadeTransition",
            parentClass: "ShaderTransition",
            directProperties: [
                KivyPropertyInfo(name: "fs", type: .stringProperty),
            ]
        ),
        "FallOutTransition": KivyWidgetInfo(
            widgetName: "FallOutTransition",
            parentClass: "ShaderTransition",
            directProperties: [
                KivyPropertyInfo(name: "duration", type: .numericProperty),
                KivyPropertyInfo(name: "fs", type: .stringProperty),
            ]
        ),
        "FileChooser": KivyWidgetInfo(
            widgetName: "FileChooser",
            parentClass: "FileChooserController",
            directProperties: [
                KivyPropertyInfo(name: "_view_list", type: .listProperty),
                KivyPropertyInfo(name: "_view_mode", type: .stringProperty),
                KivyPropertyInfo(name: "manager", type: .objectProperty),
                KivyPropertyInfo(name: "view_list", type: .aliasProperty),
                KivyPropertyInfo(name: "view_mode", type: .aliasProperty),
            ]
        ),
        "FileChooserController": KivyWidgetInfo(
            widgetName: "FileChooserController",
            parentClass: "RelativeLayout",
            directProperties: [
                KivyPropertyInfo(name: "dirselect", type: .booleanProperty),
                KivyPropertyInfo(name: "file_system", type: .objectProperty),
                KivyPropertyInfo(name: "files", type: .listProperty),
                KivyPropertyInfo(name: "filter_dirs", type: .booleanProperty),
                KivyPropertyInfo(name: "filters", type: .listProperty),
                KivyPropertyInfo(name: "font_name", type: .stringProperty),
                KivyPropertyInfo(name: "layout", type: .objectProperty),
                KivyPropertyInfo(name: "multiselect", type: .booleanProperty),
                KivyPropertyInfo(name: "path", type: .stringProperty),
                KivyPropertyInfo(name: "progress_cls", type: .objectProperty),
                KivyPropertyInfo(name: "rootpath", type: .stringProperty),
                KivyPropertyInfo(name: "selection", type: .listProperty),
                KivyPropertyInfo(name: "show_hidden", type: .booleanProperty),
                KivyPropertyInfo(name: "sort_func", type: .objectProperty),
            ]
        ),
        "FileChooserLayout": KivyWidgetInfo(
            widgetName: "FileChooserLayout",
            parentClass: "FloatLayout",
            directProperties: [
                KivyPropertyInfo(name: "controller", type: .objectProperty),
            ]
        ),
        "FileChooserProgressBase": KivyWidgetInfo(
            widgetName: "FileChooserProgressBase",
            parentClass: "FloatLayout",
            directProperties: [
                KivyPropertyInfo(name: "index", type: .numericProperty),
                KivyPropertyInfo(name: "path", type: .stringProperty),
                KivyPropertyInfo(name: "total", type: .numericProperty),
            ]
        ),
        "FloatLayout": KivyWidgetInfo(
            widgetName: "FloatLayout",
            parentClass: "Layout",
            directProperties: [
            ]
        ),
        "GestureContainer": KivyWidgetInfo(
            widgetName: "GestureContainer",
            parentClass: "EventDispatcher",
            directProperties: [
                KivyPropertyInfo(name: "active", type: .booleanProperty),
                KivyPropertyInfo(name: "active_strokes", type: .numericProperty),
                KivyPropertyInfo(name: "bbox", type: .dictProperty),
                KivyPropertyInfo(name: "height", type: .numericProperty),
                KivyPropertyInfo(name: "max_strokes", type: .numericProperty),
                KivyPropertyInfo(name: "was_merged", type: .booleanProperty),
                KivyPropertyInfo(name: "width", type: .numericProperty),
            ]
        ),
        "GestureSurface": KivyWidgetInfo(
            widgetName: "GestureSurface",
            parentClass: "FloatLayout",
            directProperties: [
                KivyPropertyInfo(name: "bbox_alpha", type: .numericProperty),
                KivyPropertyInfo(name: "bbox_margin", type: .numericProperty),
                KivyPropertyInfo(name: "color", type: .colorProperty),
                KivyPropertyInfo(name: "draw_bbox", type: .booleanProperty),
                KivyPropertyInfo(name: "draw_timeout", type: .numericProperty),
                KivyPropertyInfo(name: "line_width", type: .numericProperty),
                KivyPropertyInfo(name: "max_strokes", type: .numericProperty),
                KivyPropertyInfo(name: "temporal_window", type: .numericProperty),
                KivyPropertyInfo(name: "use_random_color", type: .booleanProperty),
            ]
        ),
        "GridLayout": KivyWidgetInfo(
            widgetName: "GridLayout",
            parentClass: "Layout",
            directProperties: [
                KivyPropertyInfo(name: "col_default_width", type: .numericProperty),
                KivyPropertyInfo(name: "col_force_default", type: .booleanProperty),
                KivyPropertyInfo(name: "cols", type: .boundedNumericProperty),
                KivyPropertyInfo(name: "cols_minimum", type: .dictProperty),
                KivyPropertyInfo(name: "minimum_height", type: .numericProperty),
                KivyPropertyInfo(name: "minimum_size", type: .referenceListProperty),
                KivyPropertyInfo(name: "minimum_width", type: .numericProperty),
                KivyPropertyInfo(name: "orientation", type: .optionProperty),
                KivyPropertyInfo(name: "padding", type: .variableListProperty),
                KivyPropertyInfo(name: "row_default_height", type: .numericProperty),
                KivyPropertyInfo(name: "row_force_default", type: .booleanProperty),
                KivyPropertyInfo(name: "rows", type: .boundedNumericProperty),
                KivyPropertyInfo(name: "rows_minimum", type: .dictProperty),
                KivyPropertyInfo(name: "spacing", type: .variableListProperty),
            ]
        ),
        "HorizontalBlurEffect": KivyWidgetInfo(
            widgetName: "HorizontalBlurEffect",
            parentClass: "EffectBase",
            directProperties: [
                KivyPropertyInfo(name: "size", type: .numericProperty),
            ]
        ),
        "Image": KivyWidgetInfo(
            widgetName: "Image",
            parentClass: "Widget",
            directProperties: [
                KivyPropertyInfo(name: "allow_stretch", type: .booleanProperty),
                KivyPropertyInfo(name: "anim_delay", type: .numericProperty),
                KivyPropertyInfo(name: "anim_loop", type: .numericProperty),
                KivyPropertyInfo(name: "color", type: .colorProperty),
                KivyPropertyInfo(name: "fit_mode", type: .optionProperty),
                KivyPropertyInfo(name: "image_ratio", type: .aliasProperty),
                KivyPropertyInfo(name: "keep_data", type: .booleanProperty),
                KivyPropertyInfo(name: "keep_ratio", type: .booleanProperty),
                KivyPropertyInfo(name: "mipmap", type: .booleanProperty),
                KivyPropertyInfo(name: "nocache", type: .booleanProperty),
                KivyPropertyInfo(name: "norm_image_size", type: .aliasProperty),
                KivyPropertyInfo(name: "source", type: .stringProperty),
                KivyPropertyInfo(name: "texture", type: .objectProperty),
                KivyPropertyInfo(name: "texture_size", type: .listProperty),
            ]
        ),
        "InterfaceWithSidebar": KivyWidgetInfo(
            widgetName: "InterfaceWithSidebar",
            parentClass: "BoxLayout",
            directProperties: [
                KivyPropertyInfo(name: "content", type: .objectProperty),
                KivyPropertyInfo(name: "menu", type: .objectProperty),
            ]
        ),
        "InterfaceWithSpinner": KivyWidgetInfo(
            widgetName: "InterfaceWithSpinner",
            parentClass: "BoxLayout",
            directProperties: [
                KivyPropertyInfo(name: "content", type: .objectProperty),
                KivyPropertyInfo(name: "menu", type: .objectProperty),
            ]
        ),
        "InterfaceWithTabbedPanel": KivyWidgetInfo(
            widgetName: "InterfaceWithTabbedPanel",
            parentClass: "FloatLayout",
            directProperties: [
                KivyPropertyInfo(name: "close_button", type: .objectProperty),
                KivyPropertyInfo(name: "tabbedpanel", type: .objectProperty),
            ]
        ),
        "Label": KivyWidgetInfo(
            widgetName: "Label",
            parentClass: "Widget",
            directProperties: [
                KivyPropertyInfo(name: "anchors", type: .dictProperty),
                KivyPropertyInfo(name: "base_direction", type: .optionProperty),
                KivyPropertyInfo(name: "bold", type: .booleanProperty),
                KivyPropertyInfo(name: "color", type: .colorProperty),
                KivyPropertyInfo(name: "disabled_color", type: .colorProperty),
                KivyPropertyInfo(name: "disabled_outline_color", type: .colorProperty),
                KivyPropertyInfo(name: "ellipsis_options", type: .dictProperty),
                KivyPropertyInfo(name: "font_blended", type: .booleanProperty),
                KivyPropertyInfo(name: "font_context", type: .stringProperty),
                KivyPropertyInfo(name: "font_direction", type: .optionProperty),
                KivyPropertyInfo(name: "font_family", type: .stringProperty),
                KivyPropertyInfo(name: "font_features", type: .stringProperty),
                KivyPropertyInfo(name: "font_hinting", type: .optionProperty),
                KivyPropertyInfo(name: "font_kerning", type: .booleanProperty),
                KivyPropertyInfo(name: "font_name", type: .stringProperty),
                KivyPropertyInfo(name: "font_script_name", type: .optionProperty),
                KivyPropertyInfo(name: "font_size", type: .numericProperty),
                KivyPropertyInfo(name: "halign", type: .optionProperty),
                KivyPropertyInfo(name: "is_shortened", type: .booleanProperty),
                KivyPropertyInfo(name: "italic", type: .booleanProperty),
                KivyPropertyInfo(name: "limit_render_to_text_bbox", type: .booleanProperty),
                KivyPropertyInfo(name: "line_height", type: .numericProperty),
                KivyPropertyInfo(name: "markup", type: .booleanProperty),
                KivyPropertyInfo(name: "max_lines", type: .numericProperty),
                KivyPropertyInfo(name: "mipmap", type: .booleanProperty),
                KivyPropertyInfo(name: "outline_color", type: .colorProperty),
                KivyPropertyInfo(name: "outline_width", type: .numericProperty),
                KivyPropertyInfo(name: "padding", type: .variableListProperty),
                KivyPropertyInfo(name: "padding_x", type: .numericProperty),
                KivyPropertyInfo(name: "padding_y", type: .numericProperty),
                KivyPropertyInfo(name: "refs", type: .dictProperty),
                KivyPropertyInfo(name: "shorten", type: .booleanProperty),
                KivyPropertyInfo(name: "shorten_from", type: .optionProperty),
                KivyPropertyInfo(name: "split_str", type: .stringProperty),
                KivyPropertyInfo(name: "strikethrough", type: .booleanProperty),
                KivyPropertyInfo(name: "strip", type: .booleanProperty),
                KivyPropertyInfo(name: "text", type: .stringProperty),
                KivyPropertyInfo(name: "text_language", type: .stringProperty),
                KivyPropertyInfo(name: "text_size", type: .listProperty),
                KivyPropertyInfo(name: "texture", type: .objectProperty),
                KivyPropertyInfo(name: "texture_size", type: .listProperty),
                KivyPropertyInfo(name: "underline", type: .booleanProperty),
                KivyPropertyInfo(name: "unicode_errors", type: .optionProperty),
                KivyPropertyInfo(name: "valign", type: .optionProperty),
            ]
        ),
        "Layout": KivyWidgetInfo(
            widgetName: "Layout",
            parentClass: "Widget",
            directProperties: [
            ]
        ),
        "MenuSidebar": KivyWidgetInfo(
            widgetName: "MenuSidebar",
            parentClass: "FloatLayout",
            directProperties: [
                KivyPropertyInfo(name: "buttons_layout", type: .objectProperty),
                KivyPropertyInfo(name: "close_button", type: .objectProperty),
                KivyPropertyInfo(name: "selected_uid", type: .numericProperty),
            ]
        ),
        "MenuSpinner": KivyWidgetInfo(
            widgetName: "MenuSpinner",
            parentClass: "BoxLayout",
            directProperties: [
                KivyPropertyInfo(name: "close_button", type: .objectProperty),
                KivyPropertyInfo(name: "panel_names", type: .dictProperty),
                KivyPropertyInfo(name: "selected_uid", type: .numericProperty),
                KivyPropertyInfo(name: "spinner", type: .objectProperty),
                KivyPropertyInfo(name: "spinner_text", type: .stringProperty),
            ]
        ),
        "ModalView": KivyWidgetInfo(
            widgetName: "ModalView",
            parentClass: "AnchorLayout",
            directProperties: [
                KivyPropertyInfo(name: "_anim_alpha", type: .numericProperty),
                KivyPropertyInfo(name: "_anim_duration", type: .numericProperty),
                KivyPropertyInfo(name: "_is_open", type: .booleanProperty),
                KivyPropertyInfo(name: "_window", type: .objectProperty),
                KivyPropertyInfo(name: "attach_to", type: .objectProperty),
                KivyPropertyInfo(name: "auto_dismiss", type: .booleanProperty),
                KivyPropertyInfo(name: "background", type: .stringProperty),
                KivyPropertyInfo(name: "background_color", type: .colorProperty),
                KivyPropertyInfo(name: "border", type: .listProperty),
                KivyPropertyInfo(name: "overlay_color", type: .colorProperty),
            ]
        ),
        "MyOwnActionButton": KivyWidgetInfo(
            widgetName: "MyOwnActionButton",
            parentClass: "Button",
            directProperties: [
                KivyPropertyInfo(name: "icon", type: .stringProperty),
            ]
        ),
        "MyWidget": KivyWidgetInfo(
            widgetName: "MyWidget",
            parentClass: "Widget",
            directProperties: [
                KivyPropertyInfo(name: "center", type: .referenceListProperty),
                KivyPropertyInfo(name: "center_x", type: .aliasProperty),
                KivyPropertyInfo(name: "center_y", type: .aliasProperty),
                KivyPropertyInfo(name: "children", type: .listProperty),
                KivyPropertyInfo(name: "cls", type: .listProperty),
                KivyPropertyInfo(name: "disabled", type: .aliasProperty),
                KivyPropertyInfo(name: "height", type: .numericProperty),
                KivyPropertyInfo(name: "ids", type: .dictProperty),
                KivyPropertyInfo(name: "motion_filter", type: .dictProperty),
                KivyPropertyInfo(name: "opacity", type: .numericProperty),
                KivyPropertyInfo(name: "parent", type: .objectProperty),
                KivyPropertyInfo(name: "pos", type: .referenceListProperty),
                KivyPropertyInfo(name: "pos_hint", type: .objectProperty),
                KivyPropertyInfo(name: "right", type: .aliasProperty),
                KivyPropertyInfo(name: "size", type: .referenceListProperty),
                KivyPropertyInfo(name: "size_hint", type: .referenceListProperty),
                KivyPropertyInfo(name: "size_hint_max", type: .referenceListProperty),
                KivyPropertyInfo(name: "size_hint_max_x", type: .numericProperty),
                KivyPropertyInfo(name: "size_hint_max_y", type: .numericProperty),
                KivyPropertyInfo(name: "size_hint_min", type: .referenceListProperty),
                KivyPropertyInfo(name: "size_hint_min_x", type: .numericProperty),
                KivyPropertyInfo(name: "size_hint_min_y", type: .numericProperty),
                KivyPropertyInfo(name: "size_hint_x", type: .numericProperty),
                KivyPropertyInfo(name: "size_hint_y", type: .numericProperty),
                KivyPropertyInfo(name: "top", type: .aliasProperty),
                KivyPropertyInfo(name: "width", type: .numericProperty),
                KivyPropertyInfo(name: "x", type: .numericProperty),
                KivyPropertyInfo(name: "y", type: .numericProperty),
            ]
        ),
        "NoTransition": KivyWidgetInfo(
            widgetName: "NoTransition",
            parentClass: "TransitionBase",
            directProperties: [
                KivyPropertyInfo(name: "duration", type: .numericProperty),
            ]
        ),
        "OtherWidget": KivyWidgetInfo(
            widgetName: "OtherWidget",
            parentClass: "MyWidget",
            directProperties: [
                KivyPropertyInfo(name: "center", type: .referenceListProperty),
                KivyPropertyInfo(name: "center_x", type: .aliasProperty),
                KivyPropertyInfo(name: "center_y", type: .aliasProperty),
                KivyPropertyInfo(name: "children", type: .listProperty),
                KivyPropertyInfo(name: "cls", type: .listProperty),
                KivyPropertyInfo(name: "disabled", type: .aliasProperty),
                KivyPropertyInfo(name: "height", type: .numericProperty),
                KivyPropertyInfo(name: "ids", type: .dictProperty),
                KivyPropertyInfo(name: "motion_filter", type: .dictProperty),
                KivyPropertyInfo(name: "opacity", type: .numericProperty),
                KivyPropertyInfo(name: "parent", type: .objectProperty),
                KivyPropertyInfo(name: "pos", type: .referenceListProperty),
                KivyPropertyInfo(name: "pos_hint", type: .objectProperty),
                KivyPropertyInfo(name: "right", type: .aliasProperty),
                KivyPropertyInfo(name: "size", type: .referenceListProperty),
                KivyPropertyInfo(name: "size_hint", type: .referenceListProperty),
                KivyPropertyInfo(name: "size_hint_max", type: .referenceListProperty),
                KivyPropertyInfo(name: "size_hint_max_x", type: .numericProperty),
                KivyPropertyInfo(name: "size_hint_max_y", type: .numericProperty),
                KivyPropertyInfo(name: "size_hint_min", type: .referenceListProperty),
                KivyPropertyInfo(name: "size_hint_min_x", type: .numericProperty),
                KivyPropertyInfo(name: "size_hint_min_y", type: .numericProperty),
                KivyPropertyInfo(name: "size_hint_x", type: .numericProperty),
                KivyPropertyInfo(name: "size_hint_y", type: .numericProperty),
                KivyPropertyInfo(name: "top", type: .aliasProperty),
                KivyPropertyInfo(name: "width", type: .numericProperty),
                KivyPropertyInfo(name: "x", type: .numericProperty),
                KivyPropertyInfo(name: "y", type: .numericProperty),
            ]
        ),
        "PageLayout": KivyWidgetInfo(
            widgetName: "PageLayout",
            parentClass: "Layout",
            directProperties: [
                KivyPropertyInfo(name: "anim_kwargs", type: .dictProperty),
                KivyPropertyInfo(name: "border", type: .numericProperty),
                KivyPropertyInfo(name: "page", type: .numericProperty),
                KivyPropertyInfo(name: "swipe_threshold", type: .numericProperty),
            ]
        ),
        "PixelateEffect": KivyWidgetInfo(
            widgetName: "PixelateEffect",
            parentClass: "EffectBase",
            directProperties: [
                KivyPropertyInfo(name: "pixel_size", type: .numericProperty),
            ]
        ),
        "Popup": KivyWidgetInfo(
            widgetName: "Popup",
            parentClass: "ModalView",
            directProperties: [
                KivyPropertyInfo(name: "_container", type: .objectProperty),
                KivyPropertyInfo(name: "content", type: .objectProperty),
                KivyPropertyInfo(name: "separator_color", type: .colorProperty),
                KivyPropertyInfo(name: "separator_height", type: .numericProperty),
                KivyPropertyInfo(name: "title", type: .stringProperty),
                KivyPropertyInfo(name: "title_align", type: .optionProperty),
                KivyPropertyInfo(name: "title_color", type: .colorProperty),
                KivyPropertyInfo(name: "title_font", type: .stringProperty),
                KivyPropertyInfo(name: "title_size", type: .numericProperty),
            ]
        ),
        "ProgressBar": KivyWidgetInfo(
            widgetName: "ProgressBar",
            parentClass: "Widget",
            directProperties: [
                KivyPropertyInfo(name: "max", type: .numericProperty),
                KivyPropertyInfo(name: "value", type: .aliasProperty),
                KivyPropertyInfo(name: "value_normalized", type: .aliasProperty),
            ]
        ),
        "RecycleLayout": KivyWidgetInfo(
            widgetName: "RecycleLayout",
            parentClass: "RecycleLayoutManagerBehavior",
            directProperties: [
                KivyPropertyInfo(name: "default_height", type: .numericProperty),
                KivyPropertyInfo(name: "default_pos_hint", type: .objectProperty),
                KivyPropertyInfo(name: "default_size", type: .referenceListProperty),
                KivyPropertyInfo(name: "default_size_hint", type: .referenceListProperty),
                KivyPropertyInfo(name: "default_size_hint_max", type: .referenceListProperty),
                KivyPropertyInfo(name: "default_size_hint_min", type: .referenceListProperty),
                KivyPropertyInfo(name: "default_size_hint_x", type: .numericProperty),
                KivyPropertyInfo(name: "default_size_hint_x_max", type: .numericProperty),
                KivyPropertyInfo(name: "default_size_hint_x_min", type: .numericProperty),
                KivyPropertyInfo(name: "default_size_hint_y", type: .numericProperty),
                KivyPropertyInfo(name: "default_size_hint_y_max", type: .numericProperty),
                KivyPropertyInfo(name: "default_size_hint_y_min", type: .numericProperty),
                KivyPropertyInfo(name: "default_width", type: .numericProperty),
                KivyPropertyInfo(name: "initial_height", type: .numericProperty),
                KivyPropertyInfo(name: "initial_size", type: .referenceListProperty),
                KivyPropertyInfo(name: "initial_width", type: .numericProperty),
                KivyPropertyInfo(name: "key_pos_hint", type: .stringProperty),
                KivyPropertyInfo(name: "key_size", type: .stringProperty),
                KivyPropertyInfo(name: "key_size_hint", type: .stringProperty),
                KivyPropertyInfo(name: "key_size_hint_max", type: .stringProperty),
                KivyPropertyInfo(name: "key_size_hint_min", type: .stringProperty),
            ]
        ),
        "RelativeLayout": KivyWidgetInfo(
            widgetName: "RelativeLayout",
            parentClass: "FloatLayout",
            directProperties: [
            ]
        ),
        "RiseInTransition": KivyWidgetInfo(
            widgetName: "RiseInTransition",
            parentClass: "ShaderTransition",
            directProperties: [
                KivyPropertyInfo(name: "duration", type: .numericProperty),
                KivyPropertyInfo(name: "fs", type: .stringProperty),
            ]
        ),
        "RstBlockQuote": KivyWidgetInfo(
            widgetName: "RstBlockQuote",
            parentClass: "GridLayout",
            directProperties: [
                KivyPropertyInfo(name: "content", type: .objectProperty),
            ]
        ),
        "RstDefinition": KivyWidgetInfo(
            widgetName: "RstDefinition",
            parentClass: "GridLayout",
            directProperties: [
                KivyPropertyInfo(name: "document", type: .objectProperty),
            ]
        ),
        "RstDefinitionList": KivyWidgetInfo(
            widgetName: "RstDefinitionList",
            parentClass: "GridLayout",
            directProperties: [
                KivyPropertyInfo(name: "document", type: .objectProperty),
            ]
        ),
        "RstDefinitionSpace": KivyWidgetInfo(
            widgetName: "RstDefinitionSpace",
            parentClass: "Widget",
            directProperties: [
                KivyPropertyInfo(name: "document", type: .objectProperty),
            ]
        ),
        "RstDocument": KivyWidgetInfo(
            widgetName: "RstDocument",
            parentClass: "ScrollView",
            directProperties: [
                KivyPropertyInfo(name: "anchors_widgets", type: .listProperty),
                KivyPropertyInfo(name: "background_color", type: .aliasProperty),
                KivyPropertyInfo(name: "base_font_size", type: .numericProperty),
                KivyPropertyInfo(name: "colors", type: .dictProperty),
                KivyPropertyInfo(name: "content", type: .objectProperty),
                KivyPropertyInfo(name: "document_root", type: .stringProperty),
                KivyPropertyInfo(name: "refs_assoc", type: .dictProperty),
                KivyPropertyInfo(name: "scatter", type: .objectProperty),
                KivyPropertyInfo(name: "show_errors", type: .booleanProperty),
                KivyPropertyInfo(name: "source", type: .stringProperty),
                KivyPropertyInfo(name: "source_encoding", type: .stringProperty),
                KivyPropertyInfo(name: "source_error", type: .optionProperty),
                KivyPropertyInfo(name: "text", type: .stringProperty),
                KivyPropertyInfo(name: "title", type: .stringProperty),
                KivyPropertyInfo(name: "toctrees", type: .dictProperty),
                KivyPropertyInfo(name: "underline_color", type: .stringProperty),
            ]
        ),
        "RstFieldName": KivyWidgetInfo(
            widgetName: "RstFieldName",
            parentClass: "Label",
            directProperties: [
                KivyPropertyInfo(name: "document", type: .objectProperty),
            ]
        ),
        "RstFootName": KivyWidgetInfo(
            widgetName: "RstFootName",
            parentClass: "Label",
            directProperties: [
                KivyPropertyInfo(name: "document", type: .objectProperty),
            ]
        ),
        "RstListBullet": KivyWidgetInfo(
            widgetName: "RstListBullet",
            parentClass: "Label",
            directProperties: [
                KivyPropertyInfo(name: "document", type: .objectProperty),
            ]
        ),
        "RstListItem": KivyWidgetInfo(
            widgetName: "RstListItem",
            parentClass: "GridLayout",
            directProperties: [
                KivyPropertyInfo(name: "content", type: .objectProperty),
            ]
        ),
        "RstLiteralBlock": KivyWidgetInfo(
            widgetName: "RstLiteralBlock",
            parentClass: "GridLayout",
            directProperties: [
                KivyPropertyInfo(name: "content", type: .objectProperty),
            ]
        ),
        "RstNote": KivyWidgetInfo(
            widgetName: "RstNote",
            parentClass: "GridLayout",
            directProperties: [
                KivyPropertyInfo(name: "content", type: .objectProperty),
            ]
        ),
        "RstParagraph": KivyWidgetInfo(
            widgetName: "RstParagraph",
            parentClass: "Label",
            directProperties: [
                KivyPropertyInfo(name: "document", type: .objectProperty),
                KivyPropertyInfo(name: "mx", type: .numericProperty),
                KivyPropertyInfo(name: "my", type: .numericProperty),
            ]
        ),
        "RstTerm": KivyWidgetInfo(
            widgetName: "RstTerm",
            parentClass: "AnchorLayout",
            directProperties: [
                KivyPropertyInfo(name: "document", type: .objectProperty),
                KivyPropertyInfo(name: "text", type: .stringProperty),
            ]
        ),
        "RstTitle": KivyWidgetInfo(
            widgetName: "RstTitle",
            parentClass: "Label",
            directProperties: [
                KivyPropertyInfo(name: "document", type: .objectProperty),
                KivyPropertyInfo(name: "section", type: .numericProperty),
            ]
        ),
        "RstWarning": KivyWidgetInfo(
            widgetName: "RstWarning",
            parentClass: "GridLayout",
            directProperties: [
                KivyPropertyInfo(name: "content", type: .objectProperty),
            ]
        ),
        "Scatter": KivyWidgetInfo(
            widgetName: "Scatter",
            parentClass: "Widget",
            directProperties: [
                KivyPropertyInfo(name: "auto_bring_to_front", type: .booleanProperty),
                KivyPropertyInfo(name: "bbox", type: .aliasProperty),
                KivyPropertyInfo(name: "center", type: .aliasProperty),
                KivyPropertyInfo(name: "center_x", type: .aliasProperty),
                KivyPropertyInfo(name: "center_y", type: .aliasProperty),
                KivyPropertyInfo(name: "do_collide_after_children", type: .booleanProperty),
                KivyPropertyInfo(name: "do_rotation", type: .booleanProperty),
                KivyPropertyInfo(name: "do_scale", type: .booleanProperty),
                KivyPropertyInfo(name: "do_translation", type: .aliasProperty),
                KivyPropertyInfo(name: "do_translation_x", type: .booleanProperty),
                KivyPropertyInfo(name: "do_translation_y", type: .booleanProperty),
                KivyPropertyInfo(name: "pos", type: .aliasProperty),
                KivyPropertyInfo(name: "right", type: .aliasProperty),
                KivyPropertyInfo(name: "rotation", type: .aliasProperty),
                KivyPropertyInfo(name: "scale", type: .aliasProperty),
                KivyPropertyInfo(name: "scale_max", type: .numericProperty),
                KivyPropertyInfo(name: "scale_min", type: .numericProperty),
                KivyPropertyInfo(name: "top", type: .aliasProperty),
                KivyPropertyInfo(name: "transform", type: .objectProperty),
                KivyPropertyInfo(name: "transform_inv", type: .objectProperty),
                KivyPropertyInfo(name: "translation_touches", type: .boundedNumericProperty),
                KivyPropertyInfo(name: "x", type: .aliasProperty),
                KivyPropertyInfo(name: "y", type: .aliasProperty),
            ]
        ),
        "ScatterLayout": KivyWidgetInfo(
            widgetName: "ScatterLayout",
            parentClass: "Scatter",
            directProperties: [
                KivyPropertyInfo(name: "content", type: .objectProperty),
            ]
        ),
        "Screen": KivyWidgetInfo(
            widgetName: "Screen",
            parentClass: "RelativeLayout",
            directProperties: [
                KivyPropertyInfo(name: "manager", type: .objectProperty),
                KivyPropertyInfo(name: "name", type: .stringProperty),
                KivyPropertyInfo(name: "transition_progress", type: .numericProperty),
                KivyPropertyInfo(name: "transition_state", type: .optionProperty),
            ]
        ),
        "ScreenManager": KivyWidgetInfo(
            widgetName: "ScreenManager",
            parentClass: "FloatLayout",
            directProperties: [
                KivyPropertyInfo(name: "current", type: .stringProperty),
                KivyPropertyInfo(name: "current_screen", type: .objectProperty),
                KivyPropertyInfo(name: "screen_names", type: .aliasProperty),
                KivyPropertyInfo(name: "screens", type: .listProperty),
                KivyPropertyInfo(name: "transition", type: .objectProperty),
            ]
        ),
        "ScrollView": KivyWidgetInfo(
            widgetName: "ScrollView",
            parentClass: "StencilView",
            directProperties: [
                KivyPropertyInfo(name: "_bar_color", type: .listProperty),
                KivyPropertyInfo(name: "_viewport", type: .objectProperty),
                KivyPropertyInfo(name: "always_overscroll", type: .booleanProperty),
                KivyPropertyInfo(name: "bar_color", type: .colorProperty),
                KivyPropertyInfo(name: "bar_inactive_color", type: .colorProperty),
                KivyPropertyInfo(name: "bar_margin", type: .numericProperty),
                KivyPropertyInfo(name: "bar_pos", type: .referenceListProperty),
                KivyPropertyInfo(name: "bar_pos_x", type: .optionProperty),
                KivyPropertyInfo(name: "bar_pos_y", type: .optionProperty),
                KivyPropertyInfo(name: "bar_width", type: .numericProperty),
                KivyPropertyInfo(name: "delegate_to_outer", type: .booleanProperty),
                KivyPropertyInfo(name: "do_scroll", type: .aliasProperty),
                KivyPropertyInfo(name: "do_scroll_x", type: .booleanProperty),
                KivyPropertyInfo(name: "do_scroll_y", type: .booleanProperty),
                KivyPropertyInfo(name: "effect_cls", type: .objectProperty),
                KivyPropertyInfo(name: "effect_x", type: .objectProperty),
                KivyPropertyInfo(name: "effect_y", type: .objectProperty),
                KivyPropertyInfo(name: "hbar", type: .aliasProperty),
                KivyPropertyInfo(name: "parallel_delegation", type: .booleanProperty),
                KivyPropertyInfo(name: "scroll_distance", type: .numericProperty),
                KivyPropertyInfo(name: "scroll_timeout", type: .numericProperty),
                KivyPropertyInfo(name: "scroll_type", type: .optionProperty),
                KivyPropertyInfo(name: "scroll_wheel_distance", type: .numericProperty),
                KivyPropertyInfo(name: "scroll_x", type: .numericProperty),
                KivyPropertyInfo(name: "scroll_y", type: .numericProperty),
                KivyPropertyInfo(name: "slow_device_support", type: .booleanProperty),
                KivyPropertyInfo(name: "smooth_scroll_end", type: .numericProperty),
                KivyPropertyInfo(name: "vbar", type: .aliasProperty),
                KivyPropertyInfo(name: "viewport_size", type: .listProperty),
            ]
        ),
        "Selector": KivyWidgetInfo(
            widgetName: "Selector",
            parentClass: "ButtonBehavior",
            directProperties: [
                KivyPropertyInfo(name: "matrix", type: .objectProperty),
                KivyPropertyInfo(name: "target", type: .objectProperty),
                KivyPropertyInfo(name: "window", type: .objectProperty),
            ]
        ),
        "SettingBoolean": KivyWidgetInfo(
            widgetName: "SettingBoolean",
            parentClass: "SettingItem",
            directProperties: [
                KivyPropertyInfo(name: "values", type: .listProperty),
            ]
        ),
        "SettingColor": KivyWidgetInfo(
            widgetName: "SettingColor",
            parentClass: "SettingItem",
            directProperties: [
                KivyPropertyInfo(name: "popup", type: .objectProperty),
            ]
        ),
        "SettingItem": KivyWidgetInfo(
            widgetName: "SettingItem",
            parentClass: "FloatLayout",
            directProperties: [
                KivyPropertyInfo(name: "content", type: .objectProperty),
                KivyPropertyInfo(name: "desc", type: .stringProperty),
                KivyPropertyInfo(name: "disabled", type: .booleanProperty),
                KivyPropertyInfo(name: "key", type: .stringProperty),
                KivyPropertyInfo(name: "panel", type: .objectProperty),
                KivyPropertyInfo(name: "section", type: .stringProperty),
                KivyPropertyInfo(name: "selected_alpha", type: .numericProperty),
                KivyPropertyInfo(name: "title", type: .stringProperty),
                KivyPropertyInfo(name: "value", type: .objectProperty),
            ]
        ),
        "SettingOptions": KivyWidgetInfo(
            widgetName: "SettingOptions",
            parentClass: "SettingItem",
            directProperties: [
                KivyPropertyInfo(name: "options", type: .listProperty),
                KivyPropertyInfo(name: "popup", type: .objectProperty),
            ]
        ),
        "SettingPath": KivyWidgetInfo(
            widgetName: "SettingPath",
            parentClass: "SettingItem",
            directProperties: [
                KivyPropertyInfo(name: "dirselect", type: .booleanProperty),
                KivyPropertyInfo(name: "popup", type: .objectProperty),
                KivyPropertyInfo(name: "show_hidden", type: .booleanProperty),
                KivyPropertyInfo(name: "textinput", type: .objectProperty),
            ]
        ),
        "SettingSidebarLabel": KivyWidgetInfo(
            widgetName: "SettingSidebarLabel",
            parentClass: "Label",
            directProperties: [
                KivyPropertyInfo(name: "menu", type: .objectProperty),
                KivyPropertyInfo(name: "selected", type: .booleanProperty),
                KivyPropertyInfo(name: "uid", type: .numericProperty),
            ]
        ),
        "SettingString": KivyWidgetInfo(
            widgetName: "SettingString",
            parentClass: "SettingItem",
            directProperties: [
                KivyPropertyInfo(name: "popup", type: .objectProperty),
                KivyPropertyInfo(name: "textinput", type: .objectProperty),
            ]
        ),
        "SettingTitle": KivyWidgetInfo(
            widgetName: "SettingTitle",
            parentClass: "Label",
            directProperties: [
                KivyPropertyInfo(name: "panel", type: .objectProperty),
                KivyPropertyInfo(name: "title", type: .stringProperty),
            ]
        ),
        "Settings": KivyWidgetInfo(
            widgetName: "Settings",
            parentClass: "BoxLayout",
            directProperties: [
                KivyPropertyInfo(name: "interface", type: .objectProperty),
                KivyPropertyInfo(name: "interface_cls", type: .objectProperty),
            ]
        ),
        "SettingsPanel": KivyWidgetInfo(
            widgetName: "SettingsPanel",
            parentClass: "GridLayout",
            directProperties: [
                KivyPropertyInfo(name: "config", type: .objectProperty),
                KivyPropertyInfo(name: "settings", type: .objectProperty),
                KivyPropertyInfo(name: "title", type: .stringProperty),
            ]
        ),
        "ShaderTransition": KivyWidgetInfo(
            widgetName: "ShaderTransition",
            parentClass: "TransitionBase",
            directProperties: [
                KivyPropertyInfo(name: "clearcolor", type: .colorProperty),
                KivyPropertyInfo(name: "fs", type: .stringProperty),
                KivyPropertyInfo(name: "vs", type: .stringProperty),
            ]
        ),
        "SlideTransition": KivyWidgetInfo(
            widgetName: "SlideTransition",
            parentClass: "TransitionBase",
            directProperties: [
                KivyPropertyInfo(name: "direction", type: .optionProperty),
            ]
        ),
        "Slider": KivyWidgetInfo(
            widgetName: "Slider",
            parentClass: "Widget",
            directProperties: [
                KivyPropertyInfo(name: "background_disabled_horizontal", type: .stringProperty),
                KivyPropertyInfo(name: "background_disabled_vertical", type: .stringProperty),
                KivyPropertyInfo(name: "background_horizontal", type: .stringProperty),
                KivyPropertyInfo(name: "background_vertical", type: .stringProperty),
                KivyPropertyInfo(name: "background_width", type: .numericProperty),
                KivyPropertyInfo(name: "border_horizontal", type: .listProperty),
                KivyPropertyInfo(name: "border_vertical", type: .listProperty),
                KivyPropertyInfo(name: "cursor_disabled_image", type: .stringProperty),
                KivyPropertyInfo(name: "cursor_height", type: .numericProperty),
                KivyPropertyInfo(name: "cursor_image", type: .stringProperty),
                KivyPropertyInfo(name: "cursor_size", type: .referenceListProperty),
                KivyPropertyInfo(name: "cursor_width", type: .numericProperty),
                KivyPropertyInfo(name: "max", type: .numericProperty),
                KivyPropertyInfo(name: "min", type: .numericProperty),
                KivyPropertyInfo(name: "orientation", type: .optionProperty),
                KivyPropertyInfo(name: "padding", type: .numericProperty),
                KivyPropertyInfo(name: "range", type: .referenceListProperty),
                KivyPropertyInfo(name: "sensitivity", type: .optionProperty),
                KivyPropertyInfo(name: "step", type: .boundedNumericProperty),
                KivyPropertyInfo(name: "value", type: .numericProperty),
                KivyPropertyInfo(name: "value_normalized", type: .aliasProperty),
                KivyPropertyInfo(name: "value_pos", type: .aliasProperty),
                KivyPropertyInfo(name: "value_track", type: .booleanProperty),
                KivyPropertyInfo(name: "value_track_color", type: .colorProperty),
                KivyPropertyInfo(name: "value_track_width", type: .numericProperty),
            ]
        ),
        "Spinner": KivyWidgetInfo(
            widgetName: "Spinner",
            parentClass: "Button",
            directProperties: [
                KivyPropertyInfo(name: "dropdown_cls", type: .objectProperty),
                KivyPropertyInfo(name: "is_open", type: .booleanProperty),
                KivyPropertyInfo(name: "option_cls", type: .objectProperty),
                KivyPropertyInfo(name: "sync_height", type: .booleanProperty),
                KivyPropertyInfo(name: "text_autoupdate", type: .booleanProperty),
                KivyPropertyInfo(name: "values", type: .listProperty),
            ]
        ),
        "Splitter": KivyWidgetInfo(
            widgetName: "Splitter",
            parentClass: "BoxLayout",
            directProperties: [
                KivyPropertyInfo(name: "_bound_parent", type: .objectProperty),
                KivyPropertyInfo(name: "_parent_proportion", type: .numericProperty),
                KivyPropertyInfo(name: "border", type: .listProperty),
                KivyPropertyInfo(name: "keep_within_parent", type: .booleanProperty),
                KivyPropertyInfo(name: "max_size", type: .numericProperty),
                KivyPropertyInfo(name: "min_size", type: .numericProperty),
                KivyPropertyInfo(name: "rescale_with_parent", type: .booleanProperty),
                KivyPropertyInfo(name: "sizable_from", type: .optionProperty),
                KivyPropertyInfo(name: "strip_cls", type: .objectProperty),
                KivyPropertyInfo(name: "strip_size", type: .numericProperty),
            ]
        ),
        "StackLayout": KivyWidgetInfo(
            widgetName: "StackLayout",
            parentClass: "Layout",
            directProperties: [
                KivyPropertyInfo(name: "minimum_height", type: .numericProperty),
                KivyPropertyInfo(name: "minimum_size", type: .referenceListProperty),
                KivyPropertyInfo(name: "minimum_width", type: .numericProperty),
                KivyPropertyInfo(name: "orientation", type: .optionProperty),
                KivyPropertyInfo(name: "padding", type: .variableListProperty),
                KivyPropertyInfo(name: "spacing", type: .variableListProperty),
            ]
        ),
        "StripLayout": KivyWidgetInfo(
            widgetName: "StripLayout",
            parentClass: "GridLayout",
            directProperties: [
                KivyPropertyInfo(name: "background_image", type: .stringProperty),
                KivyPropertyInfo(name: "border", type: .listProperty),
            ]
        ),
        "Switch": KivyWidgetInfo(
            widgetName: "Switch",
            parentClass: "Widget",
            directProperties: [
                KivyPropertyInfo(name: "active", type: .booleanProperty),
                KivyPropertyInfo(name: "active_norm_pos", type: .numericProperty),
                KivyPropertyInfo(name: "touch_control", type: .objectProperty),
                KivyPropertyInfo(name: "touch_distance", type: .numericProperty),
            ]
        ),
        "TabbedPanel": KivyWidgetInfo(
            widgetName: "TabbedPanel",
            parentClass: "GridLayout",
            directProperties: [
                KivyPropertyInfo(name: "_current_tab", type: .objectProperty),
                KivyPropertyInfo(name: "_default_tab", type: .objectProperty),
                KivyPropertyInfo(name: "background_color", type: .colorProperty),
                KivyPropertyInfo(name: "background_disabled_image", type: .stringProperty),
                KivyPropertyInfo(name: "background_image", type: .stringProperty),
                KivyPropertyInfo(name: "bar_width", type: .numericProperty),
                KivyPropertyInfo(name: "border", type: .listProperty),
                KivyPropertyInfo(name: "content", type: .objectProperty),
                KivyPropertyInfo(name: "current_tab", type: .aliasProperty),
                KivyPropertyInfo(name: "default_tab", type: .aliasProperty),
                KivyPropertyInfo(name: "default_tab_cls", type: .objectProperty),
                KivyPropertyInfo(name: "default_tab_content", type: .aliasProperty),
                KivyPropertyInfo(name: "default_tab_text", type: .stringProperty),
                KivyPropertyInfo(name: "do_default_tab", type: .booleanProperty),
                KivyPropertyInfo(name: "scroll_type", type: .optionProperty),
                KivyPropertyInfo(name: "strip_border", type: .listProperty),
                KivyPropertyInfo(name: "strip_image", type: .stringProperty),
                KivyPropertyInfo(name: "tab_height", type: .numericProperty),
                KivyPropertyInfo(name: "tab_list", type: .aliasProperty),
                KivyPropertyInfo(name: "tab_pos", type: .optionProperty),
                KivyPropertyInfo(name: "tab_width", type: .numericProperty),
            ]
        ),
        "TabbedPanelHeader": KivyWidgetInfo(
            widgetName: "TabbedPanelHeader",
            parentClass: "ToggleButton",
            directProperties: [
                KivyPropertyInfo(name: "content", type: .objectProperty),
            ]
        ),
        "TabbedPanelStrip": KivyWidgetInfo(
            widgetName: "TabbedPanelStrip",
            parentClass: "GridLayout",
            directProperties: [
                KivyPropertyInfo(name: "tabbed_panel", type: .objectProperty),
            ]
        ),
        "TextInput": KivyWidgetInfo(
            widgetName: "TextInput",
            parentClass: "FocusBehavior",
            directProperties: [
                KivyPropertyInfo(name: "_cursor_blink", type: .booleanProperty),
                KivyPropertyInfo(name: "_cursor_visual_height", type: .aliasProperty),
                KivyPropertyInfo(name: "_cursor_visual_pos", type: .aliasProperty),
                KivyPropertyInfo(name: "_editable", type: .booleanProperty),
                KivyPropertyInfo(name: "_hint_text", type: .stringProperty),
                KivyPropertyInfo(name: "_hint_text_lines", type: .listProperty),
                KivyPropertyInfo(name: "_ime_composition", type: .stringProperty),
                KivyPropertyInfo(name: "_ime_cursor", type: .listProperty),
                KivyPropertyInfo(name: "_lines", type: .listProperty),
                KivyPropertyInfo(name: "allow_copy", type: .booleanProperty),
                KivyPropertyInfo(name: "auto_indent", type: .booleanProperty),
                KivyPropertyInfo(name: "background_active", type: .stringProperty),
                KivyPropertyInfo(name: "background_color", type: .colorProperty),
                KivyPropertyInfo(name: "background_disabled_normal", type: .stringProperty),
                KivyPropertyInfo(name: "background_normal", type: .stringProperty),
                KivyPropertyInfo(name: "base_direction", type: .optionProperty),
                KivyPropertyInfo(name: "border", type: .listProperty),
                KivyPropertyInfo(name: "cursor", type: .aliasProperty),
                KivyPropertyInfo(name: "cursor_blink", type: .booleanProperty),
                KivyPropertyInfo(name: "cursor_col", type: .aliasProperty),
                KivyPropertyInfo(name: "cursor_color", type: .colorProperty),
                KivyPropertyInfo(name: "cursor_pos", type: .aliasProperty),
                KivyPropertyInfo(name: "cursor_row", type: .aliasProperty),
                KivyPropertyInfo(name: "cursor_width", type: .numericProperty),
                KivyPropertyInfo(name: "disabled_foreground_color", type: .colorProperty),
                KivyPropertyInfo(name: "do_wrap", type: .booleanProperty),
                KivyPropertyInfo(name: "font_context", type: .stringProperty),
                KivyPropertyInfo(name: "font_family", type: .stringProperty),
                KivyPropertyInfo(name: "font_name", type: .stringProperty),
                KivyPropertyInfo(name: "font_size", type: .numericProperty),
                KivyPropertyInfo(name: "foreground_color", type: .colorProperty),
                KivyPropertyInfo(name: "halign", type: .optionProperty),
                KivyPropertyInfo(name: "handle_image_left", type: .stringProperty),
                KivyPropertyInfo(name: "handle_image_middle", type: .stringProperty),
                KivyPropertyInfo(name: "handle_image_right", type: .stringProperty),
                KivyPropertyInfo(name: "hint_text", type: .aliasProperty),
                KivyPropertyInfo(name: "hint_text_color", type: .colorProperty),
                KivyPropertyInfo(name: "input_filter", type: .objectProperty),
                KivyPropertyInfo(name: "line_height", type: .numericProperty),
                KivyPropertyInfo(name: "line_spacing", type: .numericProperty),
                KivyPropertyInfo(name: "lines_to_scroll", type: .boundedNumericProperty),
                KivyPropertyInfo(name: "minimum_height", type: .aliasProperty),
                KivyPropertyInfo(name: "multiline", type: .booleanProperty),
                KivyPropertyInfo(name: "padding", type: .variableListProperty),
                KivyPropertyInfo(name: "password", type: .booleanProperty),
                KivyPropertyInfo(name: "password_mask", type: .stringProperty),
                KivyPropertyInfo(name: "readonly", type: .booleanProperty),
                KivyPropertyInfo(name: "replace_crlf", type: .booleanProperty),
                KivyPropertyInfo(name: "scroll_distance", type: .numericProperty),
                KivyPropertyInfo(name: "scroll_from_swipe", type: .booleanProperty),
                KivyPropertyInfo(name: "scroll_timeout", type: .numericProperty),
                KivyPropertyInfo(name: "scroll_x", type: .numericProperty),
                KivyPropertyInfo(name: "scroll_y", type: .numericProperty),
                KivyPropertyInfo(name: "selection_color", type: .colorProperty),
                KivyPropertyInfo(name: "selection_from", type: .aliasProperty),
                KivyPropertyInfo(name: "selection_text", type: .stringProperty),
                KivyPropertyInfo(name: "selection_to", type: .aliasProperty),
                KivyPropertyInfo(name: "tab_width", type: .numericProperty),
                KivyPropertyInfo(name: "text", type: .aliasProperty),
                KivyPropertyInfo(name: "text_language", type: .stringProperty),
                KivyPropertyInfo(name: "text_validate_unfocus", type: .booleanProperty),
                KivyPropertyInfo(name: "time", type: .numericProperty),
                KivyPropertyInfo(name: "use_bubble", type: .booleanProperty),
                KivyPropertyInfo(name: "use_handles", type: .booleanProperty),
                KivyPropertyInfo(name: "write_tab", type: .booleanProperty),
            ]
        ),
        "TextInputApp": KivyWidgetInfo(
            widgetName: "TextInputApp",
            parentClass: "App",
            directProperties: [
                KivyPropertyInfo(name: "time", type: .numericProperty),
            ]
        ),
        "TextInputCutCopyPaste": KivyWidgetInfo(
            widgetName: "TextInputCutCopyPaste",
            parentClass: "Bubble",
            directProperties: [
                KivyPropertyInfo(name: "but_copy", type: .objectProperty),
                KivyPropertyInfo(name: "but_cut", type: .objectProperty),
                KivyPropertyInfo(name: "but_paste", type: .objectProperty),
                KivyPropertyInfo(name: "but_selectall", type: .objectProperty),
                KivyPropertyInfo(name: "matrix", type: .objectProperty),
                KivyPropertyInfo(name: "textinput", type: .objectProperty),
            ]
        ),
        "TransitionBase": KivyWidgetInfo(
            widgetName: "TransitionBase",
            parentClass: "EventDispatcher",
            directProperties: [
                KivyPropertyInfo(name: "_anim", type: .objectProperty),
                KivyPropertyInfo(name: "duration", type: .numericProperty),
                KivyPropertyInfo(name: "is_active", type: .booleanProperty),
                KivyPropertyInfo(name: "manager", type: .objectProperty),
                KivyPropertyInfo(name: "screen_in", type: .objectProperty),
                KivyPropertyInfo(name: "screen_out", type: .objectProperty),
            ]
        ),
        "TreeView": KivyWidgetInfo(
            widgetName: "TreeView",
            parentClass: "Widget",
            directProperties: [
                KivyPropertyInfo(name: "_root", type: .objectProperty),
                KivyPropertyInfo(name: "_selected_node", type: .objectProperty),
                KivyPropertyInfo(name: "hide_root", type: .booleanProperty),
                KivyPropertyInfo(name: "indent_level", type: .numericProperty),
                KivyPropertyInfo(name: "indent_start", type: .numericProperty),
                KivyPropertyInfo(name: "load_func", type: .objectProperty),
                KivyPropertyInfo(name: "minimum_height", type: .numericProperty),
                KivyPropertyInfo(name: "minimum_size", type: .referenceListProperty),
                KivyPropertyInfo(name: "minimum_width", type: .numericProperty),
                KivyPropertyInfo(name: "root", type: .aliasProperty),
                KivyPropertyInfo(name: "root_options", type: .objectProperty),
                KivyPropertyInfo(name: "selected_node", type: .aliasProperty),
            ]
        ),
        "TreeViewNode": KivyWidgetInfo(
            widgetName: "TreeViewNode",
            parentClass: "object",
            directProperties: [
                KivyPropertyInfo(name: "color_selected", type: .colorProperty),
                KivyPropertyInfo(name: "even_color", type: .colorProperty),
                KivyPropertyInfo(name: "is_leaf", type: .booleanProperty),
                KivyPropertyInfo(name: "is_loaded", type: .booleanProperty),
                KivyPropertyInfo(name: "is_open", type: .booleanProperty),
                KivyPropertyInfo(name: "is_selected", type: .booleanProperty),
                KivyPropertyInfo(name: "level", type: .numericProperty),
                KivyPropertyInfo(name: "no_selection", type: .booleanProperty),
                KivyPropertyInfo(name: "nodes", type: .listProperty),
                KivyPropertyInfo(name: "odd", type: .booleanProperty),
                KivyPropertyInfo(name: "odd_color", type: .colorProperty),
                KivyPropertyInfo(name: "parent_node", type: .objectProperty),
            ]
        ),
        "VKeyboard": KivyWidgetInfo(
            widgetName: "VKeyboard",
            parentClass: "Scatter",
            directProperties: [
                KivyPropertyInfo(name: "active_keys", type: .dictProperty),
                KivyPropertyInfo(name: "available_layouts", type: .dictProperty),
                KivyPropertyInfo(name: "background", type: .stringProperty),
                KivyPropertyInfo(name: "background_border", type: .listProperty),
                KivyPropertyInfo(name: "background_color", type: .colorProperty),
                KivyPropertyInfo(name: "background_disabled", type: .stringProperty),
                KivyPropertyInfo(name: "callback", type: .objectProperty),
                KivyPropertyInfo(name: "docked", type: .booleanProperty),
                KivyPropertyInfo(name: "font_name", type: .stringProperty),
                KivyPropertyInfo(name: "font_size", type: .numericProperty),
                KivyPropertyInfo(name: "have_capslock", type: .booleanProperty),
                KivyPropertyInfo(name: "have_shift", type: .booleanProperty),
                KivyPropertyInfo(name: "have_special", type: .booleanProperty),
                KivyPropertyInfo(name: "key_background_color", type: .colorProperty),
                KivyPropertyInfo(name: "key_background_down", type: .stringProperty),
                KivyPropertyInfo(name: "key_background_normal", type: .stringProperty),
                KivyPropertyInfo(name: "key_border", type: .listProperty),
                KivyPropertyInfo(name: "key_disabled_background_normal", type: .stringProperty),
                KivyPropertyInfo(name: "key_margin", type: .listProperty),
                KivyPropertyInfo(name: "layout", type: .stringProperty),
                KivyPropertyInfo(name: "layout_geometry", type: .dictProperty),
                KivyPropertyInfo(name: "layout_mode", type: .optionProperty),
                KivyPropertyInfo(name: "layout_path", type: .stringProperty),
                KivyPropertyInfo(name: "margin_hint", type: .listProperty),
                KivyPropertyInfo(name: "repeat_touch", type: .objectProperty),
                KivyPropertyInfo(name: "target", type: .objectProperty),
            ]
        ),
        "VerticalBlurEffect": KivyWidgetInfo(
            widgetName: "VerticalBlurEffect",
            parentClass: "EffectBase",
            directProperties: [
                KivyPropertyInfo(name: "size", type: .numericProperty),
            ]
        ),
        "Video": KivyWidgetInfo(
            widgetName: "Video",
            parentClass: "Image",
            directProperties: [
                KivyPropertyInfo(name: "duration", type: .numericProperty),
                KivyPropertyInfo(name: "eos", type: .booleanProperty),
                KivyPropertyInfo(name: "loaded", type: .booleanProperty),
                KivyPropertyInfo(name: "options", type: .objectProperty),
                KivyPropertyInfo(name: "position", type: .numericProperty),
                KivyPropertyInfo(name: "preview", type: .stringProperty),
                KivyPropertyInfo(name: "state", type: .optionProperty),
                KivyPropertyInfo(name: "volume", type: .numericProperty),
            ]
        ),
        "VideoPlayer": KivyWidgetInfo(
            widgetName: "VideoPlayer",
            parentClass: "GridLayout",
            directProperties: [
                KivyPropertyInfo(name: "allow_fullscreen", type: .booleanProperty),
                KivyPropertyInfo(name: "annotations", type: .stringProperty),
                KivyPropertyInfo(name: "container", type: .objectProperty),
                KivyPropertyInfo(name: "duration", type: .numericProperty),
                KivyPropertyInfo(name: "fullscreen", type: .booleanProperty),
                KivyPropertyInfo(name: "image_loading", type: .stringProperty),
                KivyPropertyInfo(name: "image_overlay_play", type: .stringProperty),
                KivyPropertyInfo(name: "image_pause", type: .stringProperty),
                KivyPropertyInfo(name: "image_play", type: .stringProperty),
                KivyPropertyInfo(name: "image_stop", type: .stringProperty),
                KivyPropertyInfo(name: "image_volumehigh", type: .stringProperty),
                KivyPropertyInfo(name: "image_volumelow", type: .stringProperty),
                KivyPropertyInfo(name: "image_volumemedium", type: .stringProperty),
                KivyPropertyInfo(name: "image_volumemuted", type: .stringProperty),
                KivyPropertyInfo(name: "options", type: .dictProperty),
                KivyPropertyInfo(name: "position", type: .numericProperty),
                KivyPropertyInfo(name: "source", type: .stringProperty),
                KivyPropertyInfo(name: "state", type: .optionProperty),
                KivyPropertyInfo(name: "thumbnail", type: .stringProperty),
                KivyPropertyInfo(name: "volume", type: .numericProperty),
            ]
        ),
        "VideoPlayerAnnotation": KivyWidgetInfo(
            widgetName: "VideoPlayerAnnotation",
            parentClass: "Label",
            directProperties: [
                KivyPropertyInfo(name: "annotation", type: .dictProperty),
                KivyPropertyInfo(name: "duration", type: .numericProperty),
                KivyPropertyInfo(name: "start", type: .numericProperty),
            ]
        ),
        "VideoPlayerPlayPause": KivyWidgetInfo(
            widgetName: "VideoPlayerPlayPause",
            parentClass: "Image",
            directProperties: [
                KivyPropertyInfo(name: "video", type: .objectProperty),
            ]
        ),
        "VideoPlayerPreview": KivyWidgetInfo(
            widgetName: "VideoPlayerPreview",
            parentClass: "FloatLayout",
            directProperties: [
                KivyPropertyInfo(name: "click_done", type: .booleanProperty),
                KivyPropertyInfo(name: "source", type: .objectProperty),
                KivyPropertyInfo(name: "video", type: .objectProperty),
            ]
        ),
        "VideoPlayerProgressBar": KivyWidgetInfo(
            widgetName: "VideoPlayerProgressBar",
            parentClass: "ProgressBar",
            directProperties: [
                KivyPropertyInfo(name: "alpha", type: .numericProperty),
                KivyPropertyInfo(name: "seek", type: .numericProperty),
                KivyPropertyInfo(name: "video", type: .objectProperty),
            ]
        ),
        "VideoPlayerStop": KivyWidgetInfo(
            widgetName: "VideoPlayerStop",
            parentClass: "Image",
            directProperties: [
                KivyPropertyInfo(name: "video", type: .objectProperty),
            ]
        ),
        "VideoPlayerVolume": KivyWidgetInfo(
            widgetName: "VideoPlayerVolume",
            parentClass: "Image",
            directProperties: [
                KivyPropertyInfo(name: "video", type: .objectProperty),
            ]
        ),
        "Widget": KivyWidgetInfo(
            widgetName: "Widget",
            parentClass: "WidgetBase",
            directProperties: [
                KivyPropertyInfo(name: "center", type: .referenceListProperty),
                KivyPropertyInfo(name: "center_x", type: .aliasProperty),
                KivyPropertyInfo(name: "center_y", type: .aliasProperty),
                KivyPropertyInfo(name: "children", type: .listProperty),
                KivyPropertyInfo(name: "cls", type: .listProperty),
                KivyPropertyInfo(name: "disabled", type: .aliasProperty),
                KivyPropertyInfo(name: "height", type: .numericProperty),
                KivyPropertyInfo(name: "ids", type: .dictProperty),
                KivyPropertyInfo(name: "motion_filter", type: .dictProperty),
                KivyPropertyInfo(name: "opacity", type: .numericProperty),
                KivyPropertyInfo(name: "parent", type: .objectProperty),
                KivyPropertyInfo(name: "pos", type: .referenceListProperty),
                KivyPropertyInfo(name: "pos_hint", type: .objectProperty),
                KivyPropertyInfo(name: "right", type: .aliasProperty),
                KivyPropertyInfo(name: "size", type: .referenceListProperty),
                KivyPropertyInfo(name: "size_hint", type: .referenceListProperty),
                KivyPropertyInfo(name: "size_hint_max", type: .referenceListProperty),
                KivyPropertyInfo(name: "size_hint_max_x", type: .numericProperty),
                KivyPropertyInfo(name: "size_hint_max_y", type: .numericProperty),
                KivyPropertyInfo(name: "size_hint_min", type: .referenceListProperty),
                KivyPropertyInfo(name: "size_hint_min_x", type: .numericProperty),
                KivyPropertyInfo(name: "size_hint_min_y", type: .numericProperty),
                KivyPropertyInfo(name: "size_hint_x", type: .numericProperty),
                KivyPropertyInfo(name: "size_hint_y", type: .numericProperty),
                KivyPropertyInfo(name: "top", type: .aliasProperty),
                KivyPropertyInfo(name: "width", type: .numericProperty),
                KivyPropertyInfo(name: "x", type: .numericProperty),
                KivyPropertyInfo(name: "y", type: .numericProperty),
            ]
        ),
        "WipeTransition": KivyWidgetInfo(
            widgetName: "WipeTransition",
            parentClass: "ShaderTransition",
            directProperties: [
                KivyPropertyInfo(name: "fs", type: .stringProperty),
            ]
        ),
    ]
    
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
    public static func getPropertyType(_ propertyName: String, on widgetName: String) -> KivyPropertyType? {
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
