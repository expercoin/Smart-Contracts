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
import '../oracles/KrakenPriceTicker.sol';

contract InvestmentTracker is AuthorizedList, Authorized {

    event TokenPurchase(address indexed _investor_address, uint256 _value, uint256 _tokens);

    using SafeMath for uint256;

    struct PendingPurchase {
      uint256 ETHUSD;        /// Exchange rate
      uint256 ethSpent;      /// Ether received
      uint256 tokensEarned;  /// Tokens to be allocated in the future
    }

    KrakenPriceTicker internal ticker;

    function InvestmentTracker(address _ticker) public {

        ticker = KrakenPriceTicker(_ticker);
    }

    /// amount of raised wei
    uint256 public weiRaised = 0;

    /// Tokens sold
    uint256 public tokensSold = 0;


    /// List of investors, i.e. msg.sender(s) who has sent in Ether
    address[] internal investors;

    /// List of investments for each investor
    mapping (address => PendingPurchase[]) internal investments;

    /// @dev Log investors and their investments
    /// @param _investor Investor's address
    /// @param _value Amount of Ether said contributor sent
    function trackInvestments(address _investor, uint256 _value) internal {

        require(_investor != address(0), "Invalid investor address.");
        require(ticker.ETHUSD() > 0, "The Ether/U.S. Dollar exchange rate not been set yet.");

        if (investments[_investor].length == 0) {
            /// First time investment from this _investor
            investors.push(_investor);
        }

        uint256 rate = ticker.ETHUSD();
        /// Was 2.5 cents per coin
        ///uint256 tokens = (_value.mul(rate).mul(uint256(2)))/uint256(5);
        /// Now it is 4 cents per coin
        uint256 tokens = (_value.mul(rate) >> 2);

        investments[_investor].push(PendingPurchase({ETHUSD: rate, ethSpent: _value, tokensEarned: tokens}));
        weiRaised = weiRaised.add(_value);
        tokensSold = tokensSold.add(tokens);
        emit TokenPurchase(msg.sender, msg.value, tokens);

    }

    /// @dev Retrieve investors' addresses
    /// @return A list of addresses
    function getInvestors() external view ifAuthorized(msg.sender, PRESIDENT) returns (address[]) {

        return investors;

    }

    /// @dev Retrieve the ETHUSD exchange rate used for the specific investment
    /// @param _investor The account associated with investments
    /// @return A list of exchange rates
    function getETHUSD(address _investor) external view ifAuthorized(msg.sender, PRESIDENT) returns (uint256[]) {

        require(investments[_investor].length > 0, "No purchases of tokens found.");
        uint256[] memory result = new uint256[](investments[_investor].length);
        for (uint256 i = 0; i < investments[_investor].length; i++)
              result[i] = investments[_investor][i].ETHUSD;
        return result;

    }


    /// @dev Retrieve token amounts bought by a single investor
    /// @param _investor The account associated with investments
    /// @return A list of token  amounts that _investor sent in
    function getTokens(address _investor) external view ifAuthorized(msg.sender, PRESIDENT) returns (uint256[]) {

        require(investments[_investor].length > 0, "No purchases of tokens found.");
        uint256[] memory result = new uint256[](investments[_investor].length);
        for (uint256 i = 0; i < investments[_investor].length; i++)
              result[i] = investments[_investor][i].tokensEarned;
        return result;

    }

    /// @dev Retrieve Ether amounts sent in by a single investor
    /// @param _investor The account associated with investments
    /// @return A list of token  amounts that _investor sent in
    function getInvestments(address _investor) external view ifAuthorized(msg.sender, PRESIDENT) returns (uint256[]) {

        require(investments[_investor].length > 0, "No investments found.");
        uint256[] memory result = new uint256[](investments[_investor].length);
        for (uint256 i = 0; i < investments[_investor].length; i++)
              result[i] = investments[_investor][i].ethSpent;
        return result;

    }

}
