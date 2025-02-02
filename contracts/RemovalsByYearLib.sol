// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import {RemovalIdLib} from "./RemovalIdLib.sol";
import {AddressArrayLib, UInt256ArrayLib} from "./ArrayLib.sol";
import "./Removal.sol";
import "./Errors.sol";

/**
 * @notice A data structure that stores the removals for a given year.
 * @param yearToRemovals A mapping from a year to the removals for that year.
 * @param earliestYear The earliest year for which there are removals.
 * @param latestYear The latest year for which there are removals.
 */
struct RemovalsByYear {
  mapping(uint256 => EnumerableSetUpgradeable.UintSet) yearToRemovals;
  uint256 earliestYear;
  uint256 latestYear;
}

/**
 * @title A library that provides a set of functions for managing removals by year.
 * @author Nori Inc.
 * @dev This library is used to manage the market's removal vintages.
 *
 * ##### Uses:
 *
 * - [EnumerableSetUpgradeable](https://docs.openzeppelin.com/contracts/4.x/api/utils#EnumerableSet) for
 * EnumerableSetUpgradeable.UintSet
 * - [AddressArrayLib](../docs/AddressArrayLib.md) for `address[]`
 * - [UInt256ArrayLib](../docs/UInt256ArrayLib.md) for `uint256[]`
 */
library RemovalsByYearLib {
  using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
  using AddressArrayLib for address[];
  using UInt256ArrayLib for uint256[];

  uint256 private constant _DEFAULT_EARLIEST_YEAR = 2**256 - 1;
  uint256 private constant _DEFAULT_LATEST_YEAR = 0;

  /**
   * @notice Inserts a new removal into the collection.
   * @dev The removal is added to the Enumerable Set that maps to the year of its year.
   * @param collection the collection from storage.
   * @param removalId a new removal to insert.
   */
  function insert(RemovalsByYear storage collection, uint256 removalId)
    internal
  {
    uint256 year = RemovalIdLib.vintage({removalId: removalId});
    if (isEmpty({collection: collection})) {
      collection.earliestYear = year;
      collection.latestYear = year;
    } else if (year < collection.earliestYear) {
      collection.earliestYear = year;
    } else if (year > collection.latestYear) {
      collection.latestYear = year;
    }
    collection.yearToRemovals[year].add({value: removalId});
  }

  /**
   * @notice Removes a removal from the collection.
   * @dev Removes the removal from the Enumerable Set that corresponds to its year.
   * @param collection the collection to search through.
   * @param removalId the removal to remove.
   */
  function remove(RemovalsByYear storage collection, uint256 removalId)
    internal
  {
    uint256 year = RemovalIdLib.vintage({removalId: removalId});
    if (!collection.yearToRemovals[year].remove({value: removalId})) {
      revert RemovalNotFoundInYear({removalId: removalId, year: year});
    }
    // If all removals were removed, check to see if there are any updates to the struct we need to make.
    if (isEmptyForYear({collection: collection, year: year})) {
      if (collection.earliestYear == collection.latestYear) {
        // If there was only one year remaining, clear the values for latest and earliest years.
        collection.earliestYear = _DEFAULT_EARLIEST_YEAR;
        collection.latestYear = _DEFAULT_LATEST_YEAR;
      } else if (year == collection.earliestYear) {
        // If this was the earliest year, find the new earliest year and update the struct.
        for (
          uint256 currentYear = collection.earliestYear + 1;
          currentYear <= collection.latestYear;
          ++currentYear
        ) {
          if (collection.yearToRemovals[currentYear].length() > 0) {
            collection.earliestYear = currentYear;
            break;
          }
        }
      } else if (year == collection.latestYear) {
        // If this was the latest year, find the new latest year and update the struct.
        for (
          uint256 currentYear = collection.latestYear - 1;
          currentYear >= collection.earliestYear;
          currentYear--
        ) {
          if (collection.yearToRemovals[currentYear].length() > 0) {
            collection.latestYear = currentYear;
            break;
          }
        }
      }
    }
  }

  /**
   * @notice Checks if the collection is empty across all years.
   * @dev Uses the latestYear property to check if any years have been set.
   * @param collection the collection from storage.
   * @return True if empty, false otherwise.
   */
  function isEmpty(RemovalsByYear storage collection)
    internal
    view
    returns (bool)
  {
    return collection.latestYear == _DEFAULT_LATEST_YEAR;
  }

  /**
   * @notice Checks if the collection is empty for a particular year.
   * @param collection the collection from storage.
   * @param year the year to check.
   * @return True if empty, false otherwise.
   */
  function isEmptyForYear(RemovalsByYear storage collection, uint256 year)
    internal
    view
    returns (bool)
  {
    return getCountForYear({collection: collection, year: year}) == 0;
  }

  /**
   * @notice Gets the next removal in the collection for sale.
   * @dev Gets the first item from the Enumerable Set that corresponds to the earliest year.
   * @param collection the collection from storage.
   * @return The next removal to sell.
   */
  function getNextRemovalForSale(RemovalsByYear storage collection)
    internal
    view
    returns (uint256)
  {
    return collection.yearToRemovals[collection.earliestYear].at({index: 0});
  }

  /**
   * @notice Gets the count of unique removal IDs for a particular year.
   * @dev Gets the size of the Enumerable Set that corresponds to the given year.
   * @param collection the collection from storage.
   * @param year the year to check.
   * @return uint256 the size of the collection.
   */
  function getCountForYear(RemovalsByYear storage collection, uint256 year)
    internal
    view
    returns (uint256)
  {
    return collection.yearToRemovals[year].length();
  }

  /**
   * @notice Gets all removal IDs belonging to all vintages for a collection.
   * @param collection the collection from storage.
   * @return removalIds an array of all removal IDs in the collection.
   */
  function getAllRemovalIds(RemovalsByYear storage collection)
    internal
    view
    returns (uint256[] memory removalIds)
  {
    uint256 latestYear = collection.latestYear;
    EnumerableSetUpgradeable.UintSet storage removalIdSet;
    uint256 totalNumberOfRemovals = 0;
    uint256 nextInsertIndex = 0;
    for (uint256 year = collection.earliestYear; year <= latestYear; ++year) {
      removalIdSet = collection.yearToRemovals[year];
      totalNumberOfRemovals += removalIdSet.length();
    }
    uint256[] memory ids = new uint256[](totalNumberOfRemovals);
    for (uint256 year = collection.earliestYear; year <= latestYear; ++year) {
      removalIdSet = collection.yearToRemovals[year];
      // Skip overflow check as for loop is indexed starting at zero.
      unchecked {
        for (uint256 i = 0; i < removalIdSet.length(); ++i) {
          ids[nextInsertIndex++] = removalIdSet.at({index: i});
        }
      }
    }
    return ids;
  }
}
