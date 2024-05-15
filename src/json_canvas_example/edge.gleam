import gleam/dynamic.{type Dynamic} as dyn
import gleam/option.{type Option}
import gleam/result

import json_canvas_example/generic_node.{type Color, type NodeId, Color, NodeId}

pub type EdgeId {
  EdgeId(String)
}

pub type Side {
  Top
  Right
  Bottom
  Left
}

fn decode_side(dyn: Dynamic) -> Result(Side, List(dyn.DecodeError)) {
  use side <- result.try(dyn.string(dyn))
  case side {
    "top" -> Ok(Top)
    "right" -> Ok(Right)
    "bottom" -> Ok(Bottom)
    "left" -> Ok(Left)
    _ -> Error([dyn.DecodeError("top, right, bottom or left", side, [])])
  }
}

pub type EdgeEndpointShape {
  WithArrow
  WithoutArrow
}

fn decode_edge_endpoint_shape(
  dyn: Dynamic,
) -> Result(EdgeEndpointShape, List(dyn.DecodeError)) {
  use shape <- result.try(dyn.string(dyn))
  case shape {
    "none" -> Ok(WithoutArrow)
    "arrow" -> Ok(WithArrow)
    _ -> Error([dyn.DecodeError("none or arrow", shape, [])])
  }
}

pub type EdgeLabel {
  EdgeLabel(String)
}

pub type Edge {
  Edge(
    id: EdgeId,
    from_node: NodeId,
    from_side: Option(Side),
    from_end: EdgeEndpointShape,
    to_node: NodeId,
    to_side: Option(Side),
    to_end: EdgeEndpointShape,
    color: Option(Color),
    label: Option(EdgeLabel),
  )
}

pub fn decode_edge(dyn: Dynamic) -> Result(Edge, List(dyn.DecodeError)) {
  dyn
  |> dyn.decode9(
    fn(
      id,
      from_node,
      from_side,
      from_end,
      to_node,
      to_side,
      to_end,
      color,
      label,
    ) {
      Edge(
        EdgeId(id),
        from_node: NodeId(from_node),
        from_side: from_side,
        from_end: option.unwrap(from_end, or: WithoutArrow),
        to_node: NodeId(to_node),
        to_side: to_side,
        to_end: option.unwrap(to_end, or: WithArrow),
        color: option.map(over: color, with: Color),
        label: option.map(over: label, with: EdgeLabel),
      )
    },
    dyn.field("id", dyn.string),
    dyn.field("fromNode", dyn.string),
    dyn.optional_field("fromSide", decode_side),
    dyn.optional_field("fromEnd", decode_edge_endpoint_shape),
    dyn.field("toNode", dyn.string),
    dyn.optional_field("toSide", decode_side),
    dyn.optional_field("toEnd", decode_edge_endpoint_shape),
    dyn.optional_field("color", dyn.string),
    dyn.optional_field("label", dyn.string),
  )
}
