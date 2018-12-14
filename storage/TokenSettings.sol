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

contract TokenSettings is AuthorizedList, Authorized {

  string public name = 'Expercoin';
  string public symbol = 'EXPR';
  uint256 public INITIAL_SUPPLY = 2750000000 * 10**18;  // 2.75 billion of ether sized tokens
  uint8 public constant decimals = 18;


  function name() public view ifAuthorized(msg.sender, INTERNAL) returns(string) {

     return name;

  }

  function setName(string _name) public ifAuthorized(msg.sender, INTERNAL) {

     name = _name;

  }

  function symbol() public view ifAuthorized(msg.sender, INTERNAL) returns(string) {

     return symbol;

  }

  function setSymbol(string _symbol) public ifAuthorized(msg.sender, INTERNAL) {

     symbol = _symbol;

  }

}
