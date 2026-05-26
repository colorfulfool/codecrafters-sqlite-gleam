import argv
import file_streams/read_stream
import gleam/bit_array
import gleam/int.{to_string}
import gleam/io
import gleam/list
import gleam/result
import gleam/string

fn read_serial_size(stream: read_stream.ReadStream) {
  let assert Ok(value) = read_varint(stream)
  case int.is_even(value) {
    True -> { value - 12 } / 2
    False -> { value - 13 } / 2
  }
}

fn read_varint(stream: read_stream.ReadStream) {
  read_varint_loop(stream, 0, 0)
}

fn read_varint_loop(stream: read_stream.ReadStream, value: Int, shift: Int) {
  let assert Ok(byte) = read_stream.read_bytes_exact(stream, 1)
  let assert <<continuation:1, chunk:7>> = byte

  let new_value = value + int.bitwise_shift_left(chunk, shift)

  case continuation {
    0 -> Ok(new_value)
    1 -> read_varint_loop(stream, new_value, shift + 7)
    _ -> Error("impossible continuation bit")
  }
}

pub fn main() {
  case argv.load().arguments {
    [database_file_path, ".dbinfo", ..] -> {
      let assert Ok(rs) = read_stream.open(database_file_path)
      let assert Ok(_bytes) = read_stream.read_bytes_exact(rs, 16)
      let assert Ok(page_size) = read_stream.read_int16_be(rs)

      let assert Ok(_bytes) = read_stream.read_bytes_exact(rs, 85)
      let assert Ok(page_cells) = read_stream.read_int16_be(rs)

      io.print("database page size: ")
      io.println(page_size |> to_string)

      io.print("number of tables: ")
      io.println(page_cells |> to_string)
    }
    [database_file_path, ".tables", ..] -> {
      let assert Ok(rs) = read_stream.open(database_file_path)
      let assert Ok(_bytes) = read_stream.read_bytes_exact(rs, 100)
      let assert Ok(_bytes) = read_stream.read_bytes_exact(rs, 3)
      let assert Ok(page_cells) = read_stream.read_int16_be(rs)
      let assert Ok(cell_content_area) = read_stream.read_int16_be(rs)
      let assert Ok(_bytes) = read_stream.read_bytes_exact(rs, 5)

      let cell_offsets =
        list.range(1, page_cells)
        |> list.map(fn(_n) { read_stream.read_int16_be(rs) })
        |> result.values

      let tables =
        cell_offsets
        |> list.map(fn(offset) {
          let assert Ok(stream) = read_stream.open(database_file_path)
          let assert Ok(_bytes) =
            read_stream.read_bytes_exact(stream, cell_content_area + offset)

          let assert Ok(_record_size) = read_varint(stream)
          let assert Ok(_rowid) = read_varint(stream)

          let assert Ok(_header_size) = read_varint(stream)

          let type_size = read_serial_size(stream)
          let name_size = read_serial_size(stream)
          let tbl_name_size = read_serial_size(stream)
          let _rootpage = read_serial_size(stream)
          let _sql_size = read_serial_size(stream)

          let assert Ok(_type_value) =
            read_stream.read_bytes_exact(stream, type_size)
          let assert Ok(_name) = read_stream.read_bytes_exact(stream, name_size)
          let assert Ok(tbl_name) =
            read_stream.read_bytes_exact(stream, tbl_name_size)

          tbl_name |> bit_array.to_string
        })
        |> result.values

      io.println(tables |> string.join(" "))
    }
    _ -> {
      io.println("Unknown command")
    }
  }
}
