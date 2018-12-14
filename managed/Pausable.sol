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

import '../infrastructure/ThisMustBeFirst.sol';
import '../storage/BasicTokenStorage.sol';
import '../auth/Authorized.sol';

contract Pausable is ThisMustBeFirst, AuthorizedList, Authorized {

  event Pause();
  event Unpause();

  /// We deploy in UNpaused state
  bool public paused = false;

  function Pausable() public AuthorizedList() Authorized() { }


  /// @dev modifier to allow actions only when the contract IS NOT paused
  modifier whenNotPaused {

    if (placeholders[bytes32(1)] != address(0)) {
        BasicTokenStorage bts = BasicTokenStorage(placeholders[bytes32(1)]);
        require(!bts.paused(), "Function cannot operate in paused state.");
    }
    else {
        require(!paused, "Function cannot operate in paused state.");
    }
    _;

  }

  /// @dev modifier to allow actions only when the contract IS paused
  modifier whenPaused {

    if (placeholders[bytes32(1)] != address(0)) {
        BasicTokenStorage bts = BasicTokenStorage(placeholders[bytes32(1)]);
        require(bts.paused(), "Function can only operate in paused state.");
    }
    else {
        require(paused, "Function can only operate in paused state.");
    }
    _;

  }

  /// @dev called by the owner to pause, triggers stopped state
  function pause() public whenNotPaused ifAuthorized(msg.sender, STAFF_MEMBER) returns (bool) {

    emit Pause();
    if (placeholders[bytes32(1)] != address(0)) {
        BasicTokenStorage bts = BasicTokenStorage(placeholders[bytes32(1)]);
        bts.setPaused(true);
    }
    else {
        paused = true;
    }
    return true;

  }

  /// @dev called by the owner to unpause, returns to normal state
  function unpause() public whenPaused ifAuthorized(msg.sender, STAFF_MEMBER) returns (bool) {

    emit Unpause();
    if (placeholders[bytes32(1)] != address(0)) {
        BasicTokenStorage bts = BasicTokenStorage(placeholders[bytes32(1)]);
        bts.setPaused(false);
    }
    else {
        paused = false;
    }
    return true;

  }

}

