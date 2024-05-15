import gleam/dict
import gleam/int
import gleam/io
import gleam/json
import gleam/list
import gleam/option.{None, Some}
import gleam/set
import simplifile

import json_canvas_example/canvas.{decode_canvas}
import json_canvas_example/generic_node.{NodeId}

pub fn main() {
  let assert Ok(input) = simplifile.read(from: "example.canvas")

  let assert Ok(canvas) =
    input
    |> json.decode(decode_canvas)

  let leaves_count =
    canvas.edges
    |> list.fold(from: dict.new(), with: fn(acc, edge) {
      let NodeId(from_node) = edge.from_node
      let NodeId(to_node) = edge.to_node
      acc
      |> dict.update(from_node, with: fn(val) {
        case val {
          Some(set) -> set
          None -> set.new()
        }
        |> set.insert(to_node)
      })
      |> dict.update(to_node, with: fn(val) {
        case val {
          Some(set) -> set
          None -> set.new()
        }
        |> set.insert(from_node)
      })
    })
    |> dict.filter(keeping: fn(_key, val) { set.size(val) <= 1 })
    |> dict.size

  io.println("Leaves count: " <> int.to_string(leaves_count))
}
