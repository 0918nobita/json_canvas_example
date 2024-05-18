import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/set
import simplifile

import json_canvas
import json_canvas/types.{NodeId}

pub fn main() {
  let assert Ok(content) = simplifile.read(from: "example.canvas")

  let assert Ok(canvas) = json_canvas.decode(content)

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

  io.println("Nodes count: " <> int.to_string(list.length(canvas.nodes)))
  io.println("Leaves count: " <> int.to_string(leaves_count))
}
