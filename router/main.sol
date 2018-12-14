/*
 * Copyright(C) 2018 by @phalexo (gitter) and Big Deeper Advisors, Inc. a Wyoming corporation.
 * All rights reserved. 
 *
 * A non-exclusive, non-transferable, perpetual license to use is hereby granted to Expercoin, Inc.
 * For questions about the license contact: bigdeeperadvisors@gmail.com
 *
 * Expercoin, Inc. can be reached via support@expercoin.com and expercoin.com website.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
 * TITLE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE
 * SOFTWARE BE LIABLE FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

pragma solidity ^0.4.23;

import '../infrastructure/References.sol';
import '../auth/Authorized.sol';

contract main is References, AuthorizedList, Authorized {

  event LogicUpgrade(address indexed _oldbiz, address indexed _newbiz);
  event StorageUpgrade(address indexed _oldvars, address indexed _newvars);

  function main(address _logic, address _storage) public Authorized() {

     require(_logic != address(0), "main: Unexpectedly logic address is 0x0.");
     require(_storage != address(0), "main: Unexpectedly storage address is 0x0.");
     references[bytes32(0)] = _logic;
     references[bytes32(1)] = _storage;

  }

  /// @dev Set an address at _key location
  /// @param _address Address to set
  /// @param _key bytes32 key location
  function setReference(address _address, bytes32 _key) external ifAuthorized(msg.sender, PRESIDENT) { 

     require(_address != address(0), "setReference: Unexpectedly _address is 0x0");

     if (_key == bytes32(0)) emit LogicUpgrade(references[bytes32(0)], _address);
     else emit StorageUpgrade(references[_key], _address);

     if (references[_key] != address(0))
          delete references[_key];

     references[_key] = _address;

  }

  /// @dev Retrieve contract address at _key location, mostly for convenience
  /// @return Contract address or 0x0 if it does not exist
  function getReference(bytes32 _key) external view ifAuthorized(msg.sender, PRESIDENT) returns(address) {

      return references[_key];

  }

  function() external payable {

      address _target = references[bytes32(0)];
      assembly {
          let _calldata := mload(0x40)
          mstore(0x40, add(_calldata, calldatasize))
          calldatacopy(_calldata, 0x0, calldatasize)
          switch delegatecall(gas, _target, _calldata, calldatasize, 0, 0)
            case 0 { revert(0, 0) }
            default {
              let _returndata := mload(0x40)
              returndatacopy(_returndata, 0, returndatasize)
              mstore(0x40, add(_returndata, returndatasize))
              return(_returndata, returndatasize)
            }
       }
   }

}

