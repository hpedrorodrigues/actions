import { jest } from '@jest/globals'

export const writeSettings =
  jest.fn<typeof import('../src/settings.js').writeSettings>()
