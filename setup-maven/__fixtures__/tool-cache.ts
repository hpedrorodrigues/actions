import type * as toolCache from '@actions/tool-cache'
import { jest } from '@jest/globals'

export const cacheDir = jest.fn<typeof toolCache.cacheDir>()
export const downloadTool = jest.fn<typeof toolCache.downloadTool>()
export const extractTar = jest.fn<typeof toolCache.extractTar>()
export const find = jest.fn<typeof toolCache.find>()
