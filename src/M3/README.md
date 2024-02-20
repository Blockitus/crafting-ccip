### Coded changes are in

```bash
#-- ../M2/CCIPTokenSender.sol::CCIPTokenSender
```

**New function added**
```javascript

   function transferTokensPayNative(
        uint64 _destinationChainSelector,
        address _receiver,
        address _token,
        uint256 _amount
    )
        external
        onlyOwner
        onlyWhitelistedChain(_destinationChainSelector)
        returns (bytes32 messageId)
    {
        if (_receiver == address(0)) revert InvalidReceiverAddress();
        Client.EVM2AnyMessage memory message = _buildCcipMessage(
            _receiver,
            _token,
            _amount,
            address(0)
        );

        uint256 fees = _ccipFeesManagement(true, _destinationChainSelector, message);

        IERC20(_token).approve(address(router), _amount);

        messageId = router.ccipSend{value:fees}(_destinationChainSelector, message);

        emit TokensTransferred(
            messageId,
            _destinationChainSelector,
            _receiver,
            _token,
            _amount,
            address(0),
            fees
        );
    }

```

**Changes onto existing functions**
```diff
 function _ccipFeesManagement(
+      bool _payNative,
        uint64 _destinationChainSelector,
        Client.EVM2AnyMessage memory _message
    ) private returns (uint256 fees) {
        fees = router.getFee(_destinationChainSelector, _message); 
        uint256 currentBalance;
+        if (_payNative){
+            currentBalance = address(this).balance;
+            if (fees > currentBalance)
+                revert InsufficientBalance(currentBalance, fees);   
        }else {
            currentBalance = linkToken.balanceOf(address(this));
            if (fees > currentBalance)
                revert InsufficientBalance(currentBalance, fees);
            linkToken.approve(address(router), fees);
        }
    }
```