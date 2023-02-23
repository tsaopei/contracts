/* eslint-disable @typescript-eslint/naming-convention -- contracts in this file match on-chain contract names which are pascal case */
import type {
  Removal,
  Market,
  LockedNORI,
  NORI,
  BridgedPolygonNORI,
  Certificate,
  LockedNORILibTestHarness,
  RemovalTestHarness,
  RestrictedNORI,
  NoriUSDC,
} from './typechain-types/index';

export interface Contracts {
  Removal?: Removal;
  NORI?: NORI;
  BridgedPolygonNORI?: BridgedPolygonNORI;
  Market?: Market;
  LockedNORI?: LockedNORI;
  RestrictedNORI?: RestrictedNORI;
  Certificate?: Certificate;
  NoriUSDC?: NoriUSDC;
  LockedNORILibTestHarness?: LockedNORILibTestHarness;
  RemovalTestHarness?: RemovalTestHarness;
}
