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

contract AuthorizedList {

    bytes32 constant PRESIDENT = keccak256("Republics President!");
    bytes32 constant STAFF_MEMBER = keccak256("Staff Member.");
    bytes32 constant AIR_DROP = keccak256("Airdrop Permission.");
    bytes32 constant INTERNAL = keccak256("Internal Authorization.");
    mapping (address => mapping(bytes32 => bool)) authorized;

}
