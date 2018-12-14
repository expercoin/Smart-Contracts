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

import "./IERC20Basic.sol";
import "../auth/Authorized.sol";

/// @title Authorized account can reclaim ERC20Basic tokens.

contract RecoverCurrency is AuthorizedList, Authorized {

  /// @dev Reclaim all ERC20Basic compatible tokens
  /// @param _address The address of the token contract
   
  function recoverToken(address _address) external ifAuthorized(msg.sender, PRESIDENT) {

    require(_address != address(0), "recoverToken: Expected non-zero address.");
    IERC20Basic token = IERC20Basic(_address);
    uint256 balance = token.balanceOf(address(this));
    token.transfer(msg.sender, balance);

  }

}
