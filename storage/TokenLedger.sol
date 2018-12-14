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

contract TokenLedger is AuthorizedList, Authorized {

  mapping(address => uint256) public balances;
  uint256 public totalSupply;

  /// Iterable accounts, need it to keep track of holders
  address[] internal accounts;
  mapping(address => uint256) internal seenBefore;


  /// @dev Retrieve the total amount of tokens
  function totalSupply() public view ifAuthorized(msg.sender, INTERNAL) returns (uint256) {

    return totalSupply;

  }

  function returnAccounts() external view ifAuthorized(msg.sender, PRESIDENT) returns (address[] holders) {

      return accounts;

  }

  /// @dev Gets balance of the specified account.
  /// @param _account Address of interest
  /// @return Balance for the passed address

  function balanceOf(address _account) public view ifAuthorized(msg.sender, INTERNAL) returns (uint256 balance) {

      return balances[_account];

  }

  function balanceOf(uint256 _id) external view ifAuthorized(msg.sender, INTERNAL) returns (uint256 balance) {

      require (_id < accounts.length, "balanceOf: Invalid index.");
      return balances[accounts[_id]];

  }

  function setBalanceOf(address _account, uint256 _balance) public ifAuthorized(msg.sender, INTERNAL) {

    balances[_account] = _balance;

  }

  function setTotalSupply(uint256 _supply) public ifAuthorized(msg.sender, INTERNAL) {

    totalSupply = _supply;

  }

}
