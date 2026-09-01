/**
 * Unit tests for the action's main functionality, src/main.ts
 *
 * To mock dependencies in ESM, you can create fixtures that export mock
 * functions and objects. For example, the core module is mocked in this test,
 * so that the actual '@actions/core' module is not imported.
 */
import { jest } from '@jest/globals'
import * as core from '../__fixtures__/core.js'
import { installMaven } from '../__fixtures__/installer.js'

// Mocks should be declared before the module being tested is imported.
jest.unstable_mockModule('@actions/core', () => core)
jest.unstable_mockModule('../src/installer.js', () => ({ installMaven }))

// The module being tested should be imported dynamically. This ensures that the
// mocks are used in place of any actual dependencies.
const { run } = await import('../src/main.js')

function mockInputs(inputs: Record<string, string>): void {
  core.getInput.mockImplementation((name) => inputs[name] ?? '')
}

describe('main.ts', () => {
  beforeEach(() => {
    mockInputs({ version: '3.9.16' })
    installMaven.mockImplementation(() =>
      Promise.resolve('/tool-cache/maven/3.9.16/arm64')
    )
  })

  afterEach(() => {
    jest.resetAllMocks()
  })

  it('Adds the Maven bin directory to the path', async () => {
    await run()

    expect(installMaven).toHaveBeenCalledWith('3.9.16', {
      mirrorUrl: '',
      mirrorToken: ''
    })
    expect(core.addPath).toHaveBeenCalledWith(
      '/tool-cache/maven/3.9.16/arm64/bin'
    )
    expect(core.exportVariable).toHaveBeenCalledWith(
      'MAVEN_HOME',
      '/tool-cache/maven/3.9.16/arm64'
    )
  })

  it('Sets the path and version outputs', async () => {
    await run()

    expect(core.setOutput).toHaveBeenCalledWith(
      'path',
      '/tool-cache/maven/3.9.16/arm64'
    )
    expect(core.setOutput).toHaveBeenCalledWith('version', '3.9.16')
  })

  it('Passes the mirror configuration to the installer', async () => {
    mockInputs({
      version: '3.9.16',
      'mirror-url': 'https://mirror.example.com/maven',
      'mirror-token': 'secret-token'
    })

    await run()

    expect(core.setSecret).toHaveBeenCalledWith('secret-token')
    expect(installMaven).toHaveBeenCalledWith('3.9.16', {
      mirrorUrl: 'https://mirror.example.com/maven',
      mirrorToken: 'secret-token'
    })
  })

  it('Does not register an empty mirror token as a secret', async () => {
    await run()

    expect(core.setSecret).not.toHaveBeenCalled()
  })

  it('Sets a failed status when the installation fails', async () => {
    installMaven.mockClear().mockRejectedValueOnce(new Error('download failed'))

    await run()

    expect(core.setFailed).toHaveBeenCalledWith('download failed')
    expect(core.setOutput).not.toHaveBeenCalled()
  })
})
