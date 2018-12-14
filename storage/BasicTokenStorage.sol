/*
 * Copyright(C) 2018 by @phalexo (gitter) and Big Deeper Advisors, Inc. a Wyoming corporation.
 * All rights reserved.
 *
 * A non-exclusive, non-transferable, perpetual license to use is hereby granted to Expercoin, Inc.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
 * TITLE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE
 * SOFTWARE BE LIABLE FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

pragma solidity ^0.4.23;

import '../auth/Authorized.sol';
import './TokenSettings.sol';
import './AllowancesLedger.sol';
import './TokenLedger.sol';

contract BasicTokenStorage is AuthorizedList, Authorized, TokenSettings, AllowancesLedger, TokenLedger {

 function BasicTokenStorage() public Authorized() { }

  /// We deploy in unpaused state
  bool public paused = false;

  function setPaused(bool _paused) public ifAuthorized(msg.sender, INTERNAL) {

     paused = _paused;

  }

  /// @dev Keep track of addresses seen before, push new ones into accounts list
  /// @param _tokenholder address to check for "newness"
  function trackAddress(address _tokenholder) public ifAuthorized(msg.sender, INTERNAL) returns (bool) {

      /// EVM's default value if not set is 0
      if (seenBefore[_tokenholder] == 0) {

          accounts.push(_tokenholder);
          /// All values will always be > 0 for real indices
          seenBefore[_tokenholder] = accounts.length;

      }

      return true;

  }

  /// @dev Delete address from seenBefore and accounts, if ex-_tokenholder's balance set to 0
  /// This is not always desired since one may want to know past holders of the token too
  /// @param _tokenholder address to delete
  function deleteAddress(address _tokenholder) public ifAuthorized(msg.sender, INTERNAL) returns (bool) {

      /// We keep in seenBefore idx + 1, 0 means address has not been seen yet
      uint256 idx = seenBefore[_tokenholder] - 1;
      require(idx < accounts.length, "Index exceeds array size.");

      /// Move the last address into the newly available slot
      accounts[idx] = accounts[accounts.length - 1];
      /// Chnage the index where seenBefore points to the deleted address' location
      seenBefore[accounts[accounts.length - 1]] = idx + 1;
      accounts.length--;
      delete seenBefore[_tokenholder];

      return true;

  }

}
