/**
 * Unit tests for the action's post step, src/cleanup.ts
 */
import { jest } from '@jest/globals'
import fs from 'node:fs/promises'
import os from 'node:os'
import path from 'node:path'
import * as core from '../__fixtures__/core.js'

// Mocks should be declared before the module being tested is imported.
jest.unstable_mockModule('@actions/core', () => core)

// The module being tested should be imported dynamically. This ensures that the
// mocks are used in place of any actual dependencies.
const { run } = await import('../src/cleanup.js')

describe('cleanup.ts', () => {
  let workDir: string

  beforeEach(async () => {
    workDir = await fs.mkdtemp(path.join(os.tmpdir(), 'setup-maven-cleanup-'))
  })

  afterEach(async () => {
    await fs.rm(workDir, { recursive: true, force: true })
    jest.resetAllMocks()
  })

  it('Removes the settings file recorded in the state', async () => {
    const settingsPath = path.join(workDir, 'settings.xml')
    await fs.writeFile(settingsPath, 'content')
    core.getState.mockReturnValueOnce(settingsPath)

    await run()

    await expect(fs.access(settingsPath)).rejects.toThrow()
    expect(core.warning).not.toHaveBeenCalled()
  })

  it('Does nothing when the main step wrote no settings', async () => {
    core.getState.mockReturnValueOnce('')

    await run()

    expect(core.info).not.toHaveBeenCalled()
    expect(core.warning).not.toHaveBeenCalled()
  })
})
