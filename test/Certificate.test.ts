import { MaxUint256 } from '@/constants/units';
import { expect, setupTest } from '@/test/helpers';
import { formatTokenAmount } from '@/utils/units';

describe('Certificate', () => {
  it('should emit a CreateCertificate event when Certificate is created', async () => {
    const removalAmount = 3;
    const {
      bpNori,
      certificate,
      market,
      removal,
      listedRemovalIds,
      removalTestHarness,
    } = await setupTest({
      userFixtures: {
        supplier: {
          removalDataToList: {
            removals: [{ amount: formatTokenAmount(removalAmount) }],
          },
        },
      },
    });
    const purchaseAmount = formatTokenAmount(1);
    const value = await market.calculateCheckoutTotal(purchaseAmount); // todo use calculateCheckoutTotal globally
    const { buyer } = hre.namedSigners;
    const { v, r, s } = await buyer.permit({
      verifyingContract: bpNori,
      spender: market.address,
      value,
    });
    const removalId = await removalTestHarness.createRemovalId(
      listedRemovalIds[0]
    );
    await expect(
      market
        .connect(buyer)
        [
          'swapFromSupplier(address,address,uint256,address,uint256,uint8,bytes32,bytes32)'
        ](
          buyer.address,
          buyer.address,
          purchaseAmount,
          hre.namedAccounts.supplier,
          MaxUint256,
          v,
          r,
          s
        )
    )
      .to.emit(certificate, 'CreateCertificate')
      .withArgs(
        removal.address,
        buyer.address,
        0,
        purchaseAmount,
        [removalId],
        [purchaseAmount],
        bpNori.address,
        await market.getPriceMultiple(),
        await market.getNoriFeePercentage()
      );
  });
});
