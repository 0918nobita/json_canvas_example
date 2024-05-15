import gleam/dynamic.{type Dynamic} as dyn

import json_canvas_example/edge.{type Edge, decode_edge}
import json_canvas_example/node.{type Node, decode_node}

pub type Canvas {
  Canvas(nodes: List(Node), edges: List(Edge))
}

pub fn decode_canvas(dyn: Dynamic) -> Result(Canvas, List(dyn.DecodeError)) {
  dyn
  |> dyn.decode2(
    Canvas,
    dyn.field("nodes", dyn.list(decode_node)),
    dyn.field("edges", dyn.list(decode_edge)),
  )
}
