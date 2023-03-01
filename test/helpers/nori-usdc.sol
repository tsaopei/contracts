/* solhint-disable contract-name-camelcase, func-name-mixedcase */
// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;
import {NoriUSDC} from "@/contracts/test/NoriUSDC.sol";
import {Global, Upgradeable} from "@/test/helpers/test.sol";
import {SignatureUtils} from "@/test/helpers/signature-utils.sol";

// todo set up forked tests instead
// example: https://github.com/Uniswap/permit2/blob/4382d768f/test/integration/MainnetToken.t.sol#L175
abstract contract UpgradeableNoriUSDC is Upgradeable {
  NoriUSDC internal _noriUSDC;
  NoriUSDC internal _noriUSDCImplementation;
  SignatureUtils internal _noriUSDCSignatureUtils;

  constructor() {
    _noriUSDC = _deployPurchaseToken();
    _noriUSDCSignatureUtils = new SignatureUtils();
  }

  function _deployPurchaseToken() internal returns (NoriUSDC) {
    _noriUSDCImplementation = new NoriUSDC();
    vm.label(address(_noriUSDCImplementation), "NoriUSDC Implementation");
    bytes memory initializer = abi.encodeWithSelector(
      _noriUSDCImplementation.initialize.selector,
      _namedAccounts.admin
    );
    NoriUSDC purchaseTokenProxy = NoriUSDC(
      _deployProxy(address(_noriUSDCImplementation), initializer)
    );
    vm.label(address(purchaseTokenProxy), "NoriUSDC Proxy");
    return purchaseTokenProxy;
  }
}

// solhint-disable-next-line no-empty-blocks, this is a test
contract NonUpgradeableNoriUSDC is NoriUSDC, Global {

}
