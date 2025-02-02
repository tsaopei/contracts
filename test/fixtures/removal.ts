import { BigNumber } from 'ethers';

import type { DecodedRemovalIdV0Struct } from '@/typechain-types/artifacts/contracts/Removal';

export const defaultRemovalTokenIdFixture: DecodedRemovalIdV0Struct = {
  idVersion: 0,
  methodology: 1,
  methodologyVersion: 0,
  vintage: 2018,
  country: '0x5553', // asciiStringToHexString('US')
  subdivision: '0x4941', // asciiStringToHexString('IA')
  supplierAddress: hre.namedAccounts?.supplier,
  subIdentifier: 99_039_930, // parcel id
};

/** This token ID is the result of `removal.createRemovalId(defaultRemovalTokenIdFixture)` */
export const defaultPackedRemovalTokenIdFixture = BigNumber.from(
  '28323967194635187783729271962109934955231132147579225830224695226832206522'
);
