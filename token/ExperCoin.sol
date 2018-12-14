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
import '../auth/Authorized.sol';
import './StandardToken.sol';
import './VariableSupplyToken.sol';
import './Airdrop.sol';

contract ExperCoin is ThisMustBeFirst, AuthorizedList, Authorized, Pausable, VariableSupplyToken, Airdrop {

  event TokenRenamed(string _name, string _symbol);

  /// @dev Initializer function that gives msg.sender/creator all of existing tokens.
  /// @param _bts address
  function setExperCoin(address _bts) public ifAuthorized(msg.sender, PRESIDENT) {
    
    // We need to initialize only fresh storage
    // If _bts is 0x0 we are just passing the state from the predecessor
    // everything is already initialized

    if (_bts != address(0)) {
        BasicTokenStorage bts = BasicTokenStorage(_bts);
        bts.setTotalSupply(bts.INITIAL_SUPPLY());
        bts.setBalanceOf(msg.sender, bts.INITIAL_SUPPLY());
        bts.trackAddress(msg.sender);
    }

  }


  /// @dev Get token name/description
  /// @return string value of token name/description
  function name() public view returns (string) {

     address placeholder = placeholders[bytes32(1)];
     require(placeholder != address(0), "name: Expected non-zero address");
     if (placeholder.call(bytes4(keccak256("name()")))) {
        assembly {
          returndatacopy(0,0, returndatasize)
          return(0, returndatasize)
        }
     }

  }

  /// @dev Get token symbol
  /// @return string value of token symbol
  function symbol() public view returns (string) {

     address placeholder = placeholders[bytes32(1)];
     require(placeholder != address(0), "symbol: Expected non-zero address");
     if (placeholder.call(bytes4(keccak256("symbol()")))) {
        assembly {
          returndatacopy(0,0, returndatasize)
          return(0, returndatasize)
        }
     }

  }

  /// @dev Returns the number of decimal places after period
  /// @return uint8 decimal places
  function decimals() public view returns (uint8) {

     address placeholder = placeholders[bytes32(1)];
     require(placeholder != address(0), "decimals: Expected non-zero address");
     BasicTokenStorage bts = BasicTokenStorage(placeholder);
     return bts.decimals();

  }


  /// @dev Change the name and symbol as necessary
  /// @param _name Replacement token nanme
  /// @param _symbol Replacement token symbol
  function rename(string _name, string _symbol) public ifAuthorized(msg.sender, STAFF_MEMBER) {

      address placeholder = placeholders[bytes32(1)];
      require(placeholder != address(0), "rename: Expected non-zero address");
      BasicTokenStorage bts = BasicTokenStorage(placeholder);
      emit TokenRenamed(_name, _symbol);
      bts.setName(_name);
      bts.setSymbol(_symbol);

  }

  /// Decline Ether
  function () public payable {
      revert();
  }

}


