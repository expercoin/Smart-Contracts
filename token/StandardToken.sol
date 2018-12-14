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

import './IERC20.sol';
import '../math/SafeMath.sol';
import '../managed/Pausable.sol';
import './BasicToken.sol';
import '../storage/BasicTokenStorage.sol';


contract StandardToken is IERC20, BasicToken {

   using SafeMath for uint256;

   /// @dev Implements ERC20 transferFrom from one address to another
   /// @param _from The source address  for tokens
   /// @param _to The destination address for tokens
   /// @param _value The number/amount to transfer
   /// @return boolean true if successful

   function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused 
                                                                            returns (bool) {

     require(placeholders[bytes32(1)] != address(0), "transferFrom: Expected non-zero address.");

     // Don't send tokens to 0x0 address, use burn function that updates totalSupply
     // and don't waste gas sending tokens to yourself
     require(_to != address(0) && _from != _to, "transferFrom: No transfers to 0x0 or wash transfers are allowed.");

     BasicTokenStorage bts = BasicTokenStorage(placeholders[bytes32(1)]);

     bts.setAllowance(_from, msg.sender, bts.getAllowance(_from, msg.sender).sub(_value));

     bts.setBalanceOf(_from, bts.balanceOf(_from).sub(_value));
     bts.setBalanceOf(_to, bts.balanceOf(_to).add(_value));

     /// Track new holders
     require(bts.trackAddress(_to), "transferFrom: Failed to add new address.");

     /// No longer track if not holders. Hm.
     if (bts.balanceOf(_from) == 0)
         require(bts.deleteAddress(_from), "transferFrom: Failed to delete non-holder's address.");

     emit Transfer(_from, _to, _value);

     return true;

   }


   /// @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   /// @param _spender The address which will spend the funds.
   /// @param _value The amount of tokens to be spent.
   /// @return boolean true if successful
  
   function approve(address _spender, uint256 _value) public whenNotPaused 
                                                             returns (bool) {

      require(placeholders[bytes32(1)] != address(0), "approve: Expected non-zero address.");
      AllowancesLedger bts = AllowancesLedger(placeholders[bytes32(1)]);

      // To mitigate race condition, set allowance for address to 0
      // first and then set the new value
      // https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

      require(_spender != address(0), "approve: Need a valid address.");
      require((_value == 0) || (bts.getAllowance(msg.sender, _spender) == 0), 
                  "approve: Allowance must be set to 0 before setting it.");

      bts.setAllowance(msg.sender, _spender, _value);
      emit Approval(msg.sender, _spender, _value);

      return true;

   }


   /// @dev Function to check the amount of tokens that a spender can spend
   /// @param _accountholder Token owner account address
   /// @param _spender Account address authorized to transfer tokens
   /// @return Amount of tokens still available to _spender.

   function allowance(address _accountholder, address _spender) public view returns (uint256) {

      require(placeholders[bytes32(1)] != address(0), "Expected non-zero address.");
      AllowancesLedger bts = AllowancesLedger(placeholders[bytes32(1)]);
      return bts.getAllowance(_accountholder, _spender);

   }

}


