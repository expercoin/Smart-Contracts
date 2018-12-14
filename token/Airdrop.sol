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
import '../auth/Authorized.sol';
import '../managed/Pausable.sol';

contract Airdrop is AuthorizedList, Authorized, Pausable {

    using SafeMath for uint256;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Airdrop(address indexed _from, uint256 _howmany);

    /// @dev airDrops tokens to a list of specified addresses
    /// @param _targets The list of beneficiaries
    /// @param _values The list of amounts to be transferred.
    function airDrop(address[] _targets, uint256[] _values) public whenNotPaused ifAuthorized(msg.sender, AIR_DROP) returns (bool) {


        /// Fail early to save gas if lengths are different
        require (_targets.length == _values.length, "airDrop: _targets and _values arrays must have equal length.");

        require(placeholders[bytes32(1)] != address(0), "airDrop: Expected non-zero address.");
        BasicTokenStorage bts = BasicTokenStorage(placeholders[bytes32(1)]);

        uint256 sourceBalance = bts.balanceOf(msg.sender);

        /// Mitigation of re-entrancy attacks
        bts.setBalanceOf(msg.sender, 0);

        for (uint256 i = 0; i < _targets.length; i++) {

            uint256 _value = _values[i];
            address _target = _targets[i];

            require(_target != address(0), "airDrop: _target address cannot be 0x0.");
            require(msg.sender != _target, "airDrop: Cannot send tokens to self (_target).");

            /// Revert if msg.sender does not have enough tokens
            sourceBalance = sourceBalance.sub(_value);
            /// Distribute tokens to _target
            bts.setBalanceOf(_target, bts.balanceOf(_target).add(_value));

            require(bts.trackAddress(_target), "airDrop: Failed to add new address.");

            emit Transfer(msg.sender, _target, _value);

        }

        /// Set to the remaining balance
        bts.setBalanceOf(msg.sender, sourceBalance);
        if (sourceBalance == 0)
             require(bts.deleteAddress(msg.sender), "airDrop: Failed to delete non-holder's address.");

        emit Airdrop(msg.sender, _targets.length);

        return true;
    }

}
