// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

/**
 * @title A library for `uint256[]`.
 * @author Nori Inc.
 * @notice This library provides a set of functions to manipulate `uint256` arrays.
 * @dev The functions in this library use gas-efficient and concise syntax to improve both DX (via concision) and UX
 * (via gas efficiency).
 */
library UInt256ArrayLib {
  /**
   * @notice Fill an array.
   * @dev Fills all of the elements of a `uint256[]` with the specified `uint256` value.
   *
   * ##### Equivalence:
   *
   * ```solidity
   * for (let i = 1; i < len + 1; i++) arr[i] = val;
   * ```
   *
   * ##### Example usage:
   *
   * ```solidity
   * new uint256[](3).fill(1); // returns: [1, 1, 1]
   * ```
   * -
   * @param from The array to fill.
   * @param val The value to fill all the indexes of the array with.
   * @return arr An array filled with the value of `val`.
   */
  function fill(uint256[] memory from, uint256 val)
    internal
    pure
    returns (uint256[] memory arr)
  {
    uint256 len = from.length;
    arr = new uint256[](len);
    assembly {
      for {
        let i := 1
      } lt(i, add(len, 1)) {
        i := add(i, 1)
      } {
        mstore(add(arr, mul(32, i)), val)
      }
    }
  }

  /**
   * @notice Sum an array.
   * @dev Sums all the elements of a `uint256[]` array.
   *
   * ##### Equivalence:
   *
   * ```solidity
   * for (let i = 0; i < data.length + 1; i++) total += arr[i];
   * ```
   *
   * ##### Example usage:
   *
   * ```solidity
   * new uint256[](10).fill(1).sum(); // sum: 10
   * ```
   * -
   * @param data The array to sum.
   * @return total The sum total of the array.
   */
  function sum(uint256[] memory data) internal pure returns (uint256 total) {
    assembly {
      let len := mload(data)
      let element := add(data, 32)
      for {
        let end := add(element, mul(len, 32))
      } lt(element, end) {
        element := add(element, 32)
      } {
        let initialTotal := total
        total := add(total, mload(element))
        if lt(total, initialTotal) {
          revert(0, 0)
        }
      }
    }
  }

  /**
   * @notice Slice an array.
   * @dev Slice an array `arr` at index `from` to an index `to` (non-inclusively).
   *
   * ##### Equivalence:
   *
   * ```solidity
   * for (uint256 i = from; i < to; ++i) new[i] = original[from + i];
   * ```
   *
   * ##### Example usage:
   *
   * ```solidity
   * new uint256[](100).fill(1).slice(0, 50); // returns: [:50]
   * ```
   * -
   * @param arr The array to slice.
   * @param from The starting index of the slice.
   * @param to The ending index of the slice.
   * @return ret The sliced array.
   */
  function slice(
    uint256[] memory arr,
    uint256 from,
    uint256 to
  ) internal pure returns (uint256[] memory ret) {
    assert(from <= to);
    assert(to <= arr.length);
    uint256 len;
    unchecked {
      len = to - from;
    }
    ret = new uint256[](len);
    assembly {
      for {
        let i := 1
      } lt(i, add(len, 1)) {
        i := add(i, 1)
      } {
        mstore(add(ret, mul(32, i)), mload(add(arr, mul(32, add(from, i)))))
      }
    }
  }

  /**
   * @notice Copy an array.
   * @dev Copy an array `from` to an array `to`.
   * @param to The array to copy to.
   * @param from The array to copy from.
   * @return The copied array.
   */
  function copy(uint256[] memory to, uint256[] memory from)
    internal
    pure
    returns (uint256[] memory)
  {
    uint256 n = from.length;
    unchecked {
      for (uint256 i = 0; i < n; ++i) to[i] = from[i];
    }
    return to;
  }
}

/**
 * @title A library for `address[]`.
 * @author Nori Inc.
 * @notice This library provides a set of functions to manipulate `address` arrays.
 * @dev The functions in this library use gas-efficient and concise syntax to improve both DX (via concision) and UX
 * (via gas efficiency).
 */
library AddressArrayLib {
  /**
   * @notice Fill an array.
   * @dev Fills all the elements of an `address` array with a value.
   *
   * ##### Equivalence:
   *
   * ```solidity
   * for (let i = 1; i < len + 1; i++) arr[i] = val;
   * ```
   *
   * ##### Example usage:
   *
   * ```solidity
   * new address[](3).fill(address(0); // returns: [address(0), address(0), address(0)]
   * ```
   * -
   * @param from The array to fill.
   * @param val The value to fill all the indexes of the array with.
   * @return arr An array filled with the value of `val`.
   */
  function fill(address[] memory from, address val)
    internal
    pure
    returns (address[] memory arr)
  {
    uint256 len = from.length;
    arr = new address[](len);
    assembly {
      for {
        let i := 1
      } lt(i, add(len, 1)) {
        i := add(i, 1)
      } {
        mstore(add(arr, mul(32, i)), val)
      }
    }
  }
}
