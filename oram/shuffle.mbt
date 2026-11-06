///|
/// Oblivious Compare-and-Swap
fn oblivious_cas(arr : Array[Block], i : Int32, j : Int32, dir : Bool) -> Unit {
  let bi = arr[i]
  let bj = arr[j]
  let should_swap = if dir { bi.id > bj.id } else { bi.id < bj.id }
  if should_swap {
    arr[i] = bj
    arr[j] = bi
  }
}

///|
/// Bitonic Merge Network
fn bitonic_merge(
  arr : Array[Block],
  low : Int32,
  count : Int32,
  dir : Bool,
) -> Unit {
  if count > 1 {
    let k = count / 2
    for i in low..<(low + k) {
      oblivious_cas(arr, i, i + k, dir)
    }
    bitonic_merge(arr, low, k, dir)
    bitonic_merge(arr, low + k, k, dir)
  }
}

///|
/// Oblivious Bitonic Sort
pub fn oblivious_sort(
  arr : Array[Block],
  low : Int32,
  count : Int32,
  dir : Bool,
) -> Unit {
  if count > 1 {
    let k = count / 2
    oblivious_sort(arr, low, k, true)
    oblivious_sort(arr, low + k, k, false)
    bitonic_merge(arr, low, count, dir)
  }
}

///|
/// Oblivious Array Permutation / Shuffle using PRG keys
pub fn oblivious_shuffle(arr : Array[Block], prg : @crypto.Prg) -> Unit {
  let len = arr.length()
  for i = len - 1; i > 0; i = i - 1 {
    let j = prg.next_int_range(0, i + 1)
    let temp = arr[i]
    arr[i] = arr[j]
    arr[j] = temp
  }
}
