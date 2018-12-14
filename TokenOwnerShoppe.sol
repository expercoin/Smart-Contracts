/*
 * Copyright(C) 2018 by @phalexo (gitter) and Big Deeper Advisors, Inc. a Wyoming corporation.
 * All rights reserved.
 *
 * A non-exclusive, non-transferable, perpetual license to use is hereby granted to Expercoin, Inc.
 *
 * For any questions about the license contact bigdeeperadvisors@gmail.com
 *
 * Expercoin, Inc. can be contacted via support@expercoin.com or through expercoin.com
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
 * TITLE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE
 * SOFTWARE BE LIABLE FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

pragma solidity ^0.4.23;
pragma experimental ABIEncoderV2;

import './math/SafeMath.sol';
import './auth/AuthorizedList.sol';
import './auth/Authorized.sol';
import './auth/WhiteList.sol';
import './managed/Pausable.sol';

import './token/IERC20Basic.sol';
import './token/IERC20.sol';
import './token/IERC20Plus.sol';

import './tracking/InvestmentTracker.sol';
import './RecoverCurrency.sol';

contract TokenOwnerShoppe is WhiteList, AuthorizedList, Authorized, Pausable, InvestmentTracker, RecoverCurrency {

  using SafeMath for uint256;

  /// start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  /// Company wallet
  address public wallet_address;

  /// upper limit of tokens to be sold
  uint256 public capTokens;

  /// Minimum acceptable Ether amount
  uint256 public minValue = uint256(1 ether)/100;

  /// Maximum acceptable Ether amount
  uint256 public maxValue = uint256(100 ether);

  /// High tide for the contract balance
  uint256 internal highWater = 10 ether;

  /// What round it is
  uint8 public round = 0;

  event EtherTransfer(address indexed _from, address indexed _to, uint256 _value);

  /// @dev Starting and ending times for sale period
  event SetPeriod(uint256 _startTime, uint256 _endTime);

  /// @notice The old convention of matching constructor names with contract name is kept
  /// for ease of searching, maintenance
  /// @param _timeFromNow is the amount of time in seconds to wait 
  /// @param _duration is the period of time for the sale in seconds
  function TokenOwnerShoppe (
          uint256 _timeFromNow, 
          uint256 _duration, 
          address _wallet_address, 
          KrakenPriceTicker _ticker,
          uint256 _cap,
          uint8 _round) public Authorized() InvestmentTracker(_ticker) {

    require(_duration > 0, "Duration of 0 seconds is not valid.");
    require(_wallet_address != address(0x0), "Wallet address is not valid.");
    require(_cap > 0, "Cap amount is not valid.");

    round = _round;

    startTime = now + _timeFromNow;
    endTime = startTime + _duration;

    capTokens = _cap;
    wallet_address = _wallet_address;

  }

  /// @dev Sets the mininum price in Wei to purchase tokens
  /// @param _minValue Minimum payment in Ether
  function setMinPrice(uint256 _minValue) public ifAuthorized(msg.sender, STAFF_MEMBER) {

      minValue = _minValue;

  }

  /// @dev Sets the maximum price in Wei to purchase tokens
  function setMaxPrice(uint256 _maxValue) public ifAuthorized(msg.sender, STAFF_MEMBER) {

      maxValue = _maxValue;

  }


  /// @dev Reset the starting and ending times for the next round
  /// @param _timeFromNow Start of the sale round
  /// @param _duration End of the sale round
  function setTimes(uint256 _timeFromNow, uint256 _duration) public ifAuthorized(msg.sender, STAFF_MEMBER) {

       //require(now < startTime || now > endTime, "Cannot change times for on-going sale.");
       require(_duration > 0, "Invalid duration.");
       startTime  = now + _timeFromNow;
       endTime = startTime + _duration;
       emit SetPeriod(startTime, endTime);

  }


  /// @dev Set the cap, i.e. how many token units  we will sell in a round
  /// remember that decimals affect this number
  /// @param _capTokens How many token units are offered in a round
  function setCap(uint256 _capTokens) public ifAuthorized(msg.sender, STAFF_MEMBER) {

     require(_capTokens  > 0, "Must have a valid token cap.");
     capTokens = _capTokens;

  }

  /// @dev Change the wallet address
  /// @param _wallet_address replacement wallet address
  function changeCompanyWallet(address _wallet_address) public ifAuthorized(msg.sender, STAFF_MEMBER) {

     require(_wallet_address != address(0), "Invalid wallet address.");
     wallet_address = _wallet_address;

  }

  /// @dev highWater determines at what contract balance Ether is forwarded
  /// @return highWater
  function getHighWater() public view ifAuthorized(msg.sender, STAFF_MEMBER) returns (uint256) {

     return highWater;

  }

  /// @dev Set the high water line/ceiling
  function setHighWater(uint256 _highWater) public ifAuthorized(msg.sender, STAFF_MEMBER) {

     highWater = _highWater;

  }

  /// Entry point to buy tokens
  function () payable public {

    /// Within the current sale period
    require(now >= startTime && now <= endTime);
    backTokenOwner();

  }

  /// @dev Main purchase function
  function backTokenOwner() internal whenNotPaused ifAuthorized(msg.sender, WHITE_LISTED) {

    require(msg.value >= minValue && msg.value <= maxValue, "Payment outside permitted bounds.");

    // Transfer Ether from the contract to wallet_address
    if (address(this).balance >= highWater) {
        /// Forward gas to the Wallet
        require(wallet_address.call.value(address(this).balance)());
        emit EtherTransfer(address(this), wallet_address, address(this).balance);
    }

    trackInvestments(msg.sender, msg.value);
    require(tokensSold <= capTokens, "Raised maximum allowable amount.");

  }

}

