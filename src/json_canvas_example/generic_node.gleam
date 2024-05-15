import gleam/dynamic.{type Dynamic} as dyn
import gleam/option.{type Option}
import gleam/result

pub type NodeType {
  TextNodeType
  FileNodeType
  LinkNodeType
  GroupNodeType
}

fn decode_node_type(dyn: Dynamic) -> Result(NodeType, List(dyn.DecodeError)) {
  use ty <- result.try(dyn.string(dyn))
  case ty {
    "text" -> Ok(TextNodeType)
    "file" -> Ok(FileNodeType)
    "link" -> Ok(LinkNodeType)
    "group" -> Ok(GroupNodeType)
    _ -> Error([dyn.DecodeError("text, file, link or group", ty, [])])
  }
}

pub type NodeId {
  NodeId(String)
}

pub type Color {
  Color(String)
}

pub type GenericNodeAttrs {
  GenericNodeAttrs(
    id: NodeId,
    ty: NodeType,
    x: Int,
    y: Int,
    width: Int,
    height: Int,
    color: Option(Color),
  )
}

pub fn decode_node_attrs(
  dyn: Dynamic,
) -> Result(GenericNodeAttrs, List(dyn.DecodeError)) {
  dyn
  |> dyn.decode7(
    fn(id, ty, x, y, width, height, color) {
      GenericNodeAttrs(
        NodeId(id),
        ty,
        x,
        y,
        width,
        height,
        option.map(over: color, with: Color),
      )
    },
    dyn.field("id", dyn.string),
    dyn.field("type", decode_node_type),
    dyn.field("x", dyn.int),
    dyn.field("y", dyn.int),
    dyn.field("width", dyn.int),
    dyn.field("height", dyn.int),
    dyn.optional_field("color", dyn.string),
  )
}
