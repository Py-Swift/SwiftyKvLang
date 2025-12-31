// KivyCanvasInstructionRegistry.swift
// Auto-generated from Kivy graphics instruction definitions
//
// This file contains information about Kivy canvas instructions including their
// properties/parameters used in KV language.

import Foundation

/// Kivy canvas instruction parameter types
public enum KivyInstructionParameterType: String, Equatable, Hashable, Sendable {
    // Numeric types
    case float = "float"
    case int = "int"
    
    // Collection types
    case tuple = "tuple"
    case list = "list"
    
    // String types
    case string = "string"
    
    // Special types
    case color = "color"  // RGBA color (tuple of 4 floats)
    case texture = "texture"
    case vector = "vector"  // 2D or 3D coordinate
    
    // Enum types
    case capStyle = "cap_style"  // 'none', 'square', 'round'
    case jointStyle = "joint_style"  // 'none', 'round', 'bevel', 'miter'
    case meshMode = "mesh_mode"  // 'points', 'line_strip', 'line_loop', 'lines', 'triangle_strip', 'triangle_fan', 'triangles'
}

/// Represents a single canvas instruction parameter with its name and type
public struct KivyInstructionParameterInfo: Equatable, Hashable, Sendable {
    public let name: String
    public let type: KivyInstructionParameterType
    public let required: Bool
    public let defaultValue: String?
    
    public init(name: String, type: KivyInstructionParameterType, required: Bool = false, defaultValue: String? = nil) {
        self.name = name
        self.type = type
        self.required = required
        self.defaultValue = defaultValue
    }
}

/// Represents a Kivy canvas instruction with its parameters
public struct KivyCanvasInstructionInfo: Sendable {
    public let instructionName: String
    public let category: KivyInstructionCategory
    public let parameters: Set<KivyInstructionParameterInfo>
    public let description: String
    
    public init(instructionName: String, category: KivyInstructionCategory, parameters: Set<KivyInstructionParameterInfo>, description: String = "") {
        self.instructionName = instructionName
        self.category = category
        self.parameters = parameters
        self.description = description
    }
}

/// Categories of canvas instructions
public enum KivyInstructionCategory: String, Equatable, Hashable, Sendable {
    case context = "Context"  // PushMatrix, PopMatrix, Rotate, Scale, Translate
    case stencil = "Stencil"  // StencilPush, StencilPop, StencilUse, StencilUnUse
    case color = "Color"      // Color
    case shape = "Shape"      // Rectangle, Ellipse, Line, etc.
    case image = "Image"      // BorderImage
    case mesh = "Mesh"        // Mesh
    case vertex = "Vertex"    // Point
}

/// Enum representing all available Kivy canvas instruction types
public enum KivyCanvasInstruction: String, CaseIterable, Equatable, Hashable, Sendable {
    // Context instructions
    case PushMatrix
    case PopMatrix
    case Rotate
    case Translate
    case Scale
    case MatrixInstruction
    
    // Stencil instructions
    case StencilPush
    case StencilPop
    case StencilUse
    case StencilUnUse
    
    // Color instruction
    case Color
    
    // Shape instructions
    case Rectangle
    case Ellipse
    case Line
    case Bezier
    case Triangle
    case Quad
    case RoundedRectangle
    case Point
    
    // Image instructions
    case BorderImage
    
    // Mesh instruction
    case Mesh
    
    // Blend instructions
    case BindTexture
    case Callback
}

/// Registry of all Kivy canvas instructions with methods to query instruction information
public class KivyCanvasInstructionRegistry {
    
    /// Dictionary mapping instruction names to their information
    private static let instructionRegistry: [KivyCanvasInstruction: KivyCanvasInstructionInfo] = [
        // MARK: - Context Instructions
        
        .PushMatrix: KivyCanvasInstructionInfo(
            instructionName: "PushMatrix",
            category: .context,
            parameters: [],
            description: "Push the current coordinate space matrix onto the stack"
        ),
        
        .PopMatrix: KivyCanvasInstructionInfo(
            instructionName: "PopMatrix",
            category: .context,
            parameters: [],
            description: "Pop the coordinate space matrix from the stack"
        ),
        
        .Rotate: KivyCanvasInstructionInfo(
            instructionName: "Rotate",
            category: .context,
            parameters: [
                KivyInstructionParameterInfo(name: "angle", type: .float, required: false, defaultValue: "0.0"),
                KivyInstructionParameterInfo(name: "axis", type: .tuple, required: false, defaultValue: "(0, 0, 1)"),
                KivyInstructionParameterInfo(name: "origin", type: .tuple, required: false, defaultValue: "None"),
            ],
            description: "Rotate the coordinate space"
        ),
        
        .Translate: KivyCanvasInstructionInfo(
            instructionName: "Translate",
            category: .context,
            parameters: [
                KivyInstructionParameterInfo(name: "x", type: .float, required: false, defaultValue: "0.0"),
                KivyInstructionParameterInfo(name: "y", type: .float, required: false, defaultValue: "0.0"),
                KivyInstructionParameterInfo(name: "z", type: .float, required: false, defaultValue: "0.0"),
            ],
            description: "Translate the coordinate space"
        ),
        
        .Scale: KivyCanvasInstructionInfo(
            instructionName: "Scale",
            category: .context,
            parameters: [
                KivyInstructionParameterInfo(name: "x", type: .float, required: false, defaultValue: "1.0"),
                KivyInstructionParameterInfo(name: "y", type: .float, required: false, defaultValue: "1.0"),
                KivyInstructionParameterInfo(name: "z", type: .float, required: false, defaultValue: "1.0"),
                KivyInstructionParameterInfo(name: "origin", type: .tuple, required: false, defaultValue: "None"),
            ],
            description: "Scale the coordinate space"
        ),
        
        .MatrixInstruction: KivyCanvasInstructionInfo(
            instructionName: "MatrixInstruction",
            category: .context,
            parameters: [
                KivyInstructionParameterInfo(name: "matrix", type: .list, required: false),
            ],
            description: "Apply a transformation matrix"
        ),
        
        // MARK: - Stencil Instructions
        
        .StencilPush: KivyCanvasInstructionInfo(
            instructionName: "StencilPush",
            category: .stencil,
            parameters: [],
            description: "Push a new stencil layer"
        ),
        
        .StencilPop: KivyCanvasInstructionInfo(
            instructionName: "StencilPop",
            category: .stencil,
            parameters: [],
            description: "Pop the current stencil layer"
        ),
        
        .StencilUse: KivyCanvasInstructionInfo(
            instructionName: "StencilUse",
            category: .stencil,
            parameters: [],
            description: "Use the current stencil buffer"
        ),
        
        .StencilUnUse: KivyCanvasInstructionInfo(
            instructionName: "StencilUnUse",
            category: .stencil,
            parameters: [],
            description: "Stop using the stencil buffer"
        ),
        
        // MARK: - Color Instruction
        
        .Color: KivyCanvasInstructionInfo(
            instructionName: "Color",
            category: .color,
            parameters: [
                KivyInstructionParameterInfo(name: "r", type: .float, required: false, defaultValue: "1.0"),
                KivyInstructionParameterInfo(name: "g", type: .float, required: false, defaultValue: "1.0"),
                KivyInstructionParameterInfo(name: "b", type: .float, required: false, defaultValue: "1.0"),
                KivyInstructionParameterInfo(name: "a", type: .float, required: false, defaultValue: "1.0"),
                KivyInstructionParameterInfo(name: "rgb", type: .color, required: false),
                KivyInstructionParameterInfo(name: "rgba", type: .color, required: false),
            ],
            description: "Set the current color for subsequent drawing instructions"
        ),
        
        // MARK: - Shape Instructions
        
        .Rectangle: KivyCanvasInstructionInfo(
            instructionName: "Rectangle",
            category: .shape,
            parameters: [
                KivyInstructionParameterInfo(name: "pos", type: .tuple, required: false, defaultValue: "(0, 0)"),
                KivyInstructionParameterInfo(name: "size", type: .tuple, required: false, defaultValue: "(100, 100)"),
                KivyInstructionParameterInfo(name: "source", type: .string, required: false),
                KivyInstructionParameterInfo(name: "tex_coords", type: .list, required: false),
            ],
            description: "Draw a rectangle"
        ),
        
        .Ellipse: KivyCanvasInstructionInfo(
            instructionName: "Ellipse",
            category: .shape,
            parameters: [
                KivyInstructionParameterInfo(name: "pos", type: .tuple, required: false, defaultValue: "(0, 0)"),
                KivyInstructionParameterInfo(name: "size", type: .tuple, required: false, defaultValue: "(100, 100)"),
                KivyInstructionParameterInfo(name: "angle_start", type: .float, required: false, defaultValue: "0"),
                KivyInstructionParameterInfo(name: "angle_end", type: .float, required: false, defaultValue: "360"),
                KivyInstructionParameterInfo(name: "segments", type: .int, required: false, defaultValue: "180"),
                KivyInstructionParameterInfo(name: "source", type: .string, required: false),
            ],
            description: "Draw an ellipse or circle"
        ),
        
        .Line: KivyCanvasInstructionInfo(
            instructionName: "Line",
            category: .shape,
            parameters: [
                KivyInstructionParameterInfo(name: "points", type: .list, required: false, defaultValue: "[]"),
                KivyInstructionParameterInfo(name: "width", type: .float, required: false, defaultValue: "1.0"),
                KivyInstructionParameterInfo(name: "cap", type: .capStyle, required: false, defaultValue: "round"),
                KivyInstructionParameterInfo(name: "joint", type: .jointStyle, required: false, defaultValue: "round"),
                KivyInstructionParameterInfo(name: "cap_precision", type: .int, required: false, defaultValue: "10"),
                KivyInstructionParameterInfo(name: "joint_precision", type: .int, required: false, defaultValue: "10"),
                KivyInstructionParameterInfo(name: "close", type: .int, required: false, defaultValue: "0"),
                KivyInstructionParameterInfo(name: "circle", type: .tuple, required: false),
                KivyInstructionParameterInfo(name: "ellipse", type: .tuple, required: false),
                KivyInstructionParameterInfo(name: "rectangle", type: .tuple, required: false),
                KivyInstructionParameterInfo(name: "bezier", type: .tuple, required: false),
                KivyInstructionParameterInfo(name: "bezier_precision", type: .int, required: false, defaultValue: "180"),
                KivyInstructionParameterInfo(name: "dash_length", type: .float, required: false, defaultValue: "1"),
                KivyInstructionParameterInfo(name: "dash_offset", type: .float, required: false, defaultValue: "0"),
            ],
            description: "Draw a line or polyline"
        ),
        
        .Bezier: KivyCanvasInstructionInfo(
            instructionName: "Bezier",
            category: .shape,
            parameters: [
                KivyInstructionParameterInfo(name: "points", type: .list, required: false, defaultValue: "[]"),
                KivyInstructionParameterInfo(name: "segments", type: .int, required: false, defaultValue: "180"),
                KivyInstructionParameterInfo(name: "loop", type: .int, required: false, defaultValue: "0"),
                KivyInstructionParameterInfo(name: "dash_length", type: .float, required: false, defaultValue: "1"),
                KivyInstructionParameterInfo(name: "dash_offset", type: .float, required: false, defaultValue: "0"),
            ],
            description: "Draw a Bezier curve"
        ),
        
        .Triangle: KivyCanvasInstructionInfo(
            instructionName: "Triangle",
            category: .shape,
            parameters: [
                KivyInstructionParameterInfo(name: "points", type: .list, required: false, defaultValue: "[]"),
            ],
            description: "Draw a triangle"
        ),
        
        .Quad: KivyCanvasInstructionInfo(
            instructionName: "Quad",
            category: .shape,
            parameters: [
                KivyInstructionParameterInfo(name: "points", type: .list, required: false, defaultValue: "[]"),
            ],
            description: "Draw a quad (4-sided polygon)"
        ),
        
        .RoundedRectangle: KivyCanvasInstructionInfo(
            instructionName: "RoundedRectangle",
            category: .shape,
            parameters: [
                KivyInstructionParameterInfo(name: "pos", type: .tuple, required: false, defaultValue: "(0, 0)"),
                KivyInstructionParameterInfo(name: "size", type: .tuple, required: false, defaultValue: "(100, 100)"),
                KivyInstructionParameterInfo(name: "radius", type: .list, required: false, defaultValue: "[(10.0,)]"),
                KivyInstructionParameterInfo(name: "segments", type: .int, required: false, defaultValue: "10"),
            ],
            description: "Draw a rectangle with rounded corners"
        ),
        
        .Point: KivyCanvasInstructionInfo(
            instructionName: "Point",
            category: .vertex,
            parameters: [
                KivyInstructionParameterInfo(name: "points", type: .list, required: false, defaultValue: "[]"),
                KivyInstructionParameterInfo(name: "pointsize", type: .float, required: false, defaultValue: "1.0"),
            ],
            description: "Draw points"
        ),
        
        // MARK: - Image Instructions
        
        .BorderImage: KivyCanvasInstructionInfo(
            instructionName: "BorderImage",
            category: .image,
            parameters: [
                KivyInstructionParameterInfo(name: "pos", type: .tuple, required: false, defaultValue: "(0, 0)"),
                KivyInstructionParameterInfo(name: "size", type: .tuple, required: false, defaultValue: "(100, 100)"),
                KivyInstructionParameterInfo(name: "source", type: .string, required: false),
                KivyInstructionParameterInfo(name: "border", type: .tuple, required: false, defaultValue: "(10, 10, 10, 10)"),
            ],
            description: "Draw a scalable image with borders (9-patch)"
        ),
        
        // MARK: - Mesh Instruction
        
        .Mesh: KivyCanvasInstructionInfo(
            instructionName: "Mesh",
            category: .mesh,
            parameters: [
                KivyInstructionParameterInfo(name: "vertices", type: .list, required: false, defaultValue: "[]"),
                KivyInstructionParameterInfo(name: "indices", type: .list, required: false, defaultValue: "[]"),
                KivyInstructionParameterInfo(name: "mode", type: .meshMode, required: false, defaultValue: "points"),
                KivyInstructionParameterInfo(name: "fmt", type: .list, required: false),
            ],
            description: "Draw a mesh with custom vertices and indices"
        ),
        
        // MARK: - Other Instructions
        
        .BindTexture: KivyCanvasInstructionInfo(
            instructionName: "BindTexture",
            category: .context,
            parameters: [
                KivyInstructionParameterInfo(name: "source", type: .string, required: false),
                KivyInstructionParameterInfo(name: "index", type: .int, required: false, defaultValue: "0"),
            ],
            description: "Bind a texture for use in custom rendering"
        ),
        
        .Callback: KivyCanvasInstructionInfo(
            instructionName: "Callback",
            category: .context,
            parameters: [
                KivyInstructionParameterInfo(name: "callback", type: .string, required: false),
            ],
            description: "Execute a callback function during rendering"
        ),
    ]
    
    // MARK: - Query Methods
    
    /// Get instruction information by enum case
    /// - Parameter instruction: The instruction enum case
    /// - Returns: Instruction information if found, nil otherwise
    public static func getInstructionInfo(_ instruction: KivyCanvasInstruction) -> KivyCanvasInstructionInfo? {
        return instructionRegistry[instruction]
    }
    
    /// Get instruction information by name
    /// - Parameter instructionName: Name of the instruction (e.g., "Rectangle", "Color")
    /// - Returns: Instruction information if found, nil otherwise
    public static func getInstructionInfo(_ instructionName: String) -> KivyCanvasInstructionInfo? {
        guard let instruction = KivyCanvasInstruction(rawValue: instructionName) else { return nil }
        return instructionRegistry[instruction]
    }
    
    /// Get all parameters for an instruction
    /// - Parameter instruction: The instruction enum case
    /// - Returns: Set of all parameters
    public static func getAllParameters(for instruction: KivyCanvasInstruction) -> Set<KivyInstructionParameterInfo> {
        guard let info = instructionRegistry[instruction] else { return [] }
        return info.parameters
    }
    
    /// Get all parameters for an instruction (string-based)
    /// - Parameter instructionName: Name of the instruction
    /// - Returns: Set of all parameters
    public static func getAllParameters(for instructionName: String) -> Set<KivyInstructionParameterInfo> {
        guard let instruction = KivyCanvasInstruction(rawValue: instructionName) else { return [] }
        return getAllParameters(for: instruction)
    }
    
    /// Check if a parameter exists on an instruction
    /// - Parameters:
    ///   - parameterName: Name of the parameter
    ///   - instruction: The instruction enum case
    /// - Returns: true if the parameter exists on the instruction
    public static func hasParameter(_ parameterName: String, on instruction: KivyCanvasInstruction) -> Bool {
        let allParams = getAllParameters(for: instruction)
        return allParams.contains { $0.name == parameterName }
    }
    
    /// Check if a parameter exists on an instruction (string-based)
    /// - Parameters:
    ///   - parameterName: Name of the parameter
    ///   - instructionName: Name of the instruction
    /// - Returns: true if the parameter exists on the instruction
    public static func hasParameter(_ parameterName: String, on instructionName: String) -> Bool {
        guard let instruction = KivyCanvasInstruction(rawValue: instructionName) else { return false }
        return hasParameter(parameterName, on: instruction)
    }
    
    /// Get the type of a parameter on an instruction
    /// - Parameters:
    ///   - parameterName: Name of the parameter
    ///   - instruction: The instruction enum case
    /// - Returns: Parameter type if found, nil otherwise
    public static func getParameterType(_ parameterName: String, on instruction: KivyCanvasInstruction) -> KivyInstructionParameterType? {
        let allParams = getAllParameters(for: instruction)
        return allParams.first { $0.name == parameterName }?.type
    }
    
    /// Get the type of a parameter on an instruction (string-based)
    /// - Parameters:
    ///   - parameterName: Name of the parameter
    ///   - instructionName: Name of the instruction
    /// - Returns: Parameter type if found, nil otherwise
    public static func getParameterType(_ parameterName: String, on instructionName: String) -> KivyInstructionParameterType? {
        guard let instruction = KivyCanvasInstruction(rawValue: instructionName) else { return nil }
        return getParameterType(parameterName, on: instruction)
    }
    
    /// Get all registered instruction names
    /// - Returns: Array of all instruction names
    public static func getAllInstructionNames() -> [String] {
        return KivyCanvasInstruction.allCases.map { $0.rawValue }.sorted()
    }
    
    /// Get all registered instructions as enum cases
    /// - Returns: Array of all instruction enum cases
    public static func getAllInstructions() -> [KivyCanvasInstruction] {
        return KivyCanvasInstruction.allCases.sorted { $0.rawValue < $1.rawValue }
    }
    
    /// Get all instructions in a specific category
    /// - Parameter category: The instruction category
    /// - Returns: Array of instructions in that category
    public static func getInstructions(in category: KivyInstructionCategory) -> [KivyCanvasInstruction] {
        return instructionRegistry.filter { $0.value.category == category }.map { $0.key }.sorted { $0.rawValue < $1.rawValue }
    }
    
    /// Check if an instruction exists in the registry
    /// - Parameter instruction: The instruction enum case
    /// - Returns: true if the instruction is registered
    public static func instructionExists(_ instruction: KivyCanvasInstruction) -> Bool {
        return instructionRegistry[instruction] != nil
    }
    
    /// Check if an instruction exists in the registry (string-based)
    /// - Parameter instructionName: Name of the instruction
    /// - Returns: true if the instruction is registered
    public static func instructionExists(_ instructionName: String) -> Bool {
        return KivyCanvasInstruction(rawValue: instructionName) != nil
    }
    
    /// Get the category of an instruction
    /// - Parameter instruction: The instruction enum case
    /// - Returns: The instruction category if found, nil otherwise
    public static func getCategory(for instruction: KivyCanvasInstruction) -> KivyInstructionCategory? {
        return instructionRegistry[instruction]?.category
    }
    
    /// Get the category of an instruction (string-based)
    /// - Parameter instructionName: Name of the instruction
    /// - Returns: The instruction category if found, nil otherwise
    public static func getCategory(for instructionName: String) -> KivyInstructionCategory? {
        guard let instruction = KivyCanvasInstruction(rawValue: instructionName) else { return nil }
        return getCategory(for: instruction)
    }
    
    /// Get parameter information for a specific parameter
    /// - Parameters:
    ///   - parameterName: Name of the parameter
    ///   - instruction: The instruction enum case
    /// - Returns: Complete parameter information if found, nil otherwise
    public static func getParameterInfo(_ parameterName: String, on instruction: KivyCanvasInstruction) -> KivyInstructionParameterInfo? {
        let allParams = getAllParameters(for: instruction)
        return allParams.first { $0.name == parameterName }
    }
    
    /// Get parameter information for a specific parameter (string-based)
    /// - Parameters:
    ///   - parameterName: Name of the parameter
    ///   - instructionName: Name of the instruction
    /// - Returns: Complete parameter information if found, nil otherwise
    public static func getParameterInfo(_ parameterName: String, on instructionName: String) -> KivyInstructionParameterInfo? {
        guard let instruction = KivyCanvasInstruction(rawValue: instructionName) else { return nil }
        return getParameterInfo(parameterName, on: instruction)
    }
}
