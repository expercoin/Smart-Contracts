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

contract AllowancesLedger is AuthorizedList, Authorized {

  mapping (address => mapping (address => uint256)) public allowances;

  /// @dev Retrieve the allowance amount that _tokenholder allows _tokenspender to spend
  /// @param _tokenholder Account that holds a token balance
  /// @param _tokenspender Account that is allowed to spend tokens
  /// @return How much of a token can be spent
  function getAllowance(address _tokenholder, 
                        address _tokenspender) public view ifAuthorized(msg.sender, INTERNAL) 
                                                           returns (uint256) {

        return allowances[_tokenholder][_tokenspender];

  }


  /// @dev Set an allowance amount that _tokenholder allows _tokenspender to spend
  /// @param _tokenholder Account that holds a token balance
  /// @param _tokenspender Account that is allowed to spend tokens
  /// @param _allowance Amount of tokens
  function setAllowance(address _tokenholder, 
                        address _tokenspender, 
                        uint256 _allowance) public ifAuthorized(msg.sender, INTERNAL) {

        allowances[_tokenholder][_tokenspender] = _allowance;

  }

}
