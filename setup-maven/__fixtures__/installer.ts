import { jest } from '@jest/globals'

export const installMaven =
  jest.fn<typeof import('../src/installer.js').installMaven>()
