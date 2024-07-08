import { ethers } from "ethers";
import { CONTRACT } from "./config";
import { oracleAbi } from "./abi";
import 'dotenv/config'

const PRIVATKEY:any = process.env.ORACLE_OWNER_ACCOUNT;
export const provider = new ethers.providers.JsonRpcProvider("https://seednode.mindchain.info");
const wallet = new ethers.Wallet(PRIVATKEY, provider);
export const oracleContract = new ethers.Contract(CONTRACT, oracleAbi, wallet);