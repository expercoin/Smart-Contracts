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

pragma solidity 0.4.23;


import '../math/SafeMath.sol';
import '../auth/Authorized.sol';
import '../storage/BasicTokenStorage.sol';
import './StandardToken.sol';
import './RecoverCurrency.sol';


contract VariableSupplyToken is AuthorizedList, Authorized, RecoverCurrency, StandardToken {

    using SafeMath for uint256;

    event Burn(address indexed _target, uint256 _value);
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);

    /// @dev burn tokens belonging to a specified address
    /// @param _target The address to burn tokens for.
    /// @param _amount The amount to be burned.
    /// @return true if successful
    function burn(address _target, uint256 _amount) public ifAuthorized(msg.sender, STAFF_MEMBER) returns (bool) {

        require(placeholders[bytes32(1)] != address(0), "burn: Expected non-zero address");
        BasicTokenStorage bts = BasicTokenStorage(placeholders[bytes32(1)]);

        bts.setBalanceOf(_target, bts.balanceOf(_target).sub(_amount));
        bts.setTotalSupply(bts.totalSupply().sub(_amount));

        /// If holder's balance becomes 0, no longer a token holder
        if (bts.balanceOf(_target) == 0)
            require(bts.deleteAddress(_target), "burn: Failed to delete non-holder's address.");

        emit Burn(_target, _amount);
        emit Transfer(_target, 0, _amount);

        return true;

    }

    /// @dev burn tokens belonging to msg.sender
    /// @param _amount The amount to be burned.
    /// @return true if successful
    function burnOwn(uint256 _amount) public returns (bool) {

        require(placeholders[bytes32(1)] != address(0), "burn: Expected non-zero address");
        BasicTokenStorage bts = BasicTokenStorage(placeholders[bytes32(1)]);

        bts.setBalanceOf(msg.sender, bts.balanceOf(msg.sender).sub(_amount));
        bts.setTotalSupply(bts.totalSupply().sub(_amount));

        /// If holder's balance becomes 0, no longer a token holder
        if (bts.balanceOf(msg.sender) == 0)
            require(bts.deleteAddress(msg.sender), "burnOwn: Failed to delete non-holder's address.");

        emit Burn(msg.sender, _amount);
        emit Transfer(msg.sender, 0, _amount);

        return true;

    }

}

