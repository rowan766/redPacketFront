import { getDefaultConfig } from '@rainbow-me/rainbowkit'

import { arbitrum,base,mainnet, optimism,polygon,sepolia } from 'wagmi/chains'

const projectId = import.meta.env.VITE_WALLETCONNECT_PROJECT_ID || 'YOUR_PROJECT_ID'

export const config = getDefaultConfig({
  appName: 'redpacket',
  projectId,
  chains: [
    mainnet,
    polygon,
    optimism,
    arbitrum,
    base,
    ...(import.meta.env.DEV ? [sepolia] : []), // 开发环境添加测试网
  ],
  ssr: false, // Vite项目设置为false
})

export const SUPPORTED_CHAINS = [mainnet, polygon, optimism, arbitrum, base, sepolia]
