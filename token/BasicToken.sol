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

import '../math/SafeMath.sol';
import './IERC20Basic.sol';
import '../managed/Pausable.sol';
import '../storage/BasicTokenStorage.sol';


contract BasicToken is IERC20Basic, Pausable {

  using SafeMath for uint256;

  /// @dev Get the total token supply
  /// @return Supply
  function totalSupply() public view returns (uint256) {

     require(placeholders[bytes32(1)] != address(0), "totalSupply: Expected non-zero address.");
     BasicTokenStorage bts = BasicTokenStorage(placeholders[bytes32(1)]);
     return bts.totalSupply();

  }

  /// @dev transfer token for a specified address
  /// @param _to The address to transfer to.
  /// @param _value The amount to be transferred.
  /// @return boolean success
  function transfer(address _to, uint256 _value) public whenNotPaused 
                                                        returns (bool) {

     require(placeholders[bytes32(1)] != address(0), "transfer: Expected non-zero address.");
     require(_to != address(0), "transfer: Cannot send to 0x0, use burn instead.");
     require(msg.sender != _to, "transfer: Cannot send tokens to self.");
     BasicTokenStorage bts = BasicTokenStorage(placeholders[bytes32(1)]);

     bts.setBalanceOf(msg.sender, bts.balanceOf(msg.sender).sub(_value));
     bts.setBalanceOf(_to, bts.balanceOf(_to).add(_value));

     require(bts.trackAddress(_to), "transfer: Failed to add new address.");
     if (bts.balanceOf(msg.sender) == 0)
         require(bts.deleteAddress(msg.sender), "transfer: Failed to delete non-holder's address.");

     emit Transfer(msg.sender, _to, _value);

     return true;

  }

  /// @dev Gets balance of the specified account.
  /// @param _account Address of interest
  /// @return Balance for the passed address
  function balanceOf(address _account) public view returns (uint256 balance) {

     require(placeholders[bytes32(1)] != address(0), "balanceOf: Expected non-zero address.");
     BasicTokenStorage bts = BasicTokenStorage(placeholders[bytes32(1)]);
     return bts.balanceOf(_account);

  }

}
