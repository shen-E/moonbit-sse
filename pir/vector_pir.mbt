///|
/// Matrix-Vector PIR Engine for Large Databases
pub struct VectorPirMatrix {
  rows : Int
  cols : Int
  matrix : Array[Array[Bytes]]
  record_size : Int
}

///|
/// Create new VectorPirMatrix
pub fn VectorPirMatrix::new(
  rows : Int,
  cols : Int,
  record_size : Int,
) -> VectorPirMatrix {
  let matrix : Array[Array[Bytes]] = []
  for _ in 0..<rows {
    let row : Array[Bytes] = []
    for _ in 0..<cols {
      let buf : FixedArray[Byte] = FixedArray::make(record_size, b'\x00')
      row.push(Bytes::from_array(buf))
    }
    matrix.push(row)
  }
  { rows, cols, matrix, record_size }
}

///|
/// Set element at (r, c)
pub fn VectorPirMatrix::set(
  self : VectorPirMatrix,
  r : Int,
  c : Int,
  data : Bytes,
) -> Unit {
  self.matrix[r][c] = data
}

///|
/// Vector-Matrix Multiply with query vector
pub fn VectorPirMatrix::eval_row_vector(
  self : VectorPirMatrix,
  query_vector : FixedArray[Bool],
) -> Array[Bytes] {
  let out_row : Array[Bytes] = []
  for col = 0; col < self.cols; col = col + 1 {
    let accum : FixedArray[Byte] = FixedArray::make(self.record_size, b'\x00')
    for row = 0; row < self.rows; row = row + 1 {
      if query_vector[row] {
        let cell = self.matrix[row][col]
        for b = 0; b < self.record_size; b = b + 1 {
          accum[b] = (accum[b].to_int() ^ cell[b].to_int()).to_byte()
        }
      }
    }
    out_row.push(Bytes::from_array(accum))
  }
  out_row
}
