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

import './AuthorizedList.sol';

contract Authorized is AuthorizedList {

    /// @dev Set the initial permission for the contract creator
    /// The contract creator can then add permissions for others
    function Authorized() public {

       authorized[msg.sender][PRESIDENT] = true;

    }


    /// @dev Ensure that _address is authorized, modifier
    /// @param _address Address to be checked, usually msg.sender
    /// @param _authorization key for specific authorization
    modifier ifAuthorized(address _address, bytes32 _authorization) {

       require(authorized[_address][_authorization] || authorized[_address][PRESIDENT], "Not authorized to access!");
       _;

    }

    /// @dev Check _address' authorization, boolean function
    /// @param _address Boolean value, true if authorized, false otherwise
    /// @param _authorization key for specific authorization
    function isAuthorized(address _address, bytes32 _authorization) public view returns (bool) {

       return authorized[_address][_authorization];

    }

    /// @dev Toggle boolean flag to allow or prevent access
    /// @param _address Boolean value, true if authorized, false otherwise
    /// @param _authorization key for specific authorization
    function toggleAuthorization(address _address, bytes32 _authorization) public ifAuthorized(msg.sender, PRESIDENT) {

       /// Prevent inadvertent self locking out, cannot change own authority
       require(_address != msg.sender, "Cannot change own permissions.");

       /// No need for lower level authorization to linger
       if (_authorization == PRESIDENT && !authorized[_address][PRESIDENT]) 
           authorized[_address][STAFF_MEMBER] = false;

       authorized[_address][_authorization] = !authorized[_address][_authorization];

    }

}
