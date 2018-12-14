/*
 *   Kraken-based ETH/USD price ticker
 *   This contract keeps in storage an updated ETH/USD price,
 *   which is updated every ~3600 seconds, unless changed.
 *
 *   Adapted for Expercoin.com by Big Deeper Advisors, Inc.
 *   bigdeeperadvisors@gmail.com
 *
 *   Contact Expercoin, Inc. at expercoin.com or e-mail support@expercoin.com
 */

pragma solidity ^0.4.23;

import "./ethereum-api/oraclizeAPI.sol";
import "../auth/Authorized.sol";
import "../RecoverCurrency.sol";

contract KrakenPriceTicker is AuthorizedList, Authorized, RecoverCurrency, usingOraclize {

    uint256 public ETHUSD;
    bool public running = true;
    uint256 public frequency;

    event newOraclizeQuery(string description);
    event newKrakenPriceTicker(string price);
    event OracleFunded(address indexed _funder, uint256 _value);


    /// Contract can receive the initial funding via its payable constructor
    function KrakenPriceTicker() public usingOraclize() payable {

        /// For testing using testrpc, the next command has to be run
        /// ethereum-bridge --dev -H localhost:8545 -a 9
        /// to get the OAR value
        /// OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);

        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        emit OracleFunded(msg.sender, msg.value);
        update();
        /// In seconds, one hour, should be longer for mainnet
        frequency = 3600;
    }

    /// @dev How often is the needed value retrieved
    /// @param _seconds Period in seconds
    function setFrequency(uint256 _seconds) external ifAuthorized(msg.sender, PRESIDENT) {

        /// Running an oracle costs Ether, set frequency to something you can afford
        require(_seconds >= 30, "At least 30 seconds wait.");
        frequency = _seconds;

    }

    function setRunning(bool _isrunning) external ifAuthorized(msg.sender, PRESIDENT) {

        running = _isrunning;

    }

    function __callback(bytes32 myid, string result, bytes proof) public {
        require (msg.sender == oraclize_cbAddress());
        ETHUSD = parseInt(result,2);
        emit newKrakenPriceTicker(result);
        if (running == true)
            update();
    }

    function update() internal {
        if (oraclize_getPrice("URL") > address(this).balance) {
            emit newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            emit newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            oraclize_query(frequency, "URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHUSD).result.XETHZUSD.c.0");
        }
    }

    function restartUpdate() external ifAuthorized(msg.sender, PRESIDENT) {

        uint256 saveFreq = frequency;
        frequency = 0;
        update();
        frequency = saveFreq;

    }

    /// Simply accept Ether to fund the oracle
    function () public payable {
        emit OracleFunded(msg.sender, msg.value);
    }

}

