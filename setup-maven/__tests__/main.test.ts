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
import { writeSettings } from '../__fixtures__/settings.js'

// Mocks should be declared before the module being tested is imported.
jest.unstable_mockModule('@actions/core', () => core)
jest.unstable_mockModule('../src/installer.js', () => ({ installMaven }))
jest.unstable_mockModule('../src/settings.js', () => ({ writeSettings }))

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
    writeSettings.mockImplementation(() => Promise.resolve(null))
  })

  afterEach(() => {
    jest.resetAllMocks()
  })

  it('Adds the Maven bin directory to the path', async () => {
    await run()

    expect(installMaven).toHaveBeenCalledWith('3.9.16', {
      mirrorUrl: '',
      mirrorToken: '',
      skipIfInstalled: true
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
      mirrorToken: 'secret-token',
      skipIfInstalled: true
    })
  })

  it('Passes skip-if-installed to the installer', async () => {
    mockInputs({ version: '3.9.16', 'skip-if-installed': 'false' })

    await run()

    expect(installMaven).toHaveBeenCalledWith('3.9.16', {
      mirrorUrl: '',
      mirrorToken: '',
      skipIfInstalled: false
    })
  })

  it('Does not register an empty mirror token as a secret', async () => {
    await run()

    expect(core.setSecret).not.toHaveBeenCalled()
  })

  it('Passes the settings inputs through', async () => {
    mockInputs({
      version: '3.9.16',
      'settings-servers': '[{"id": "x"}]',
      'settings-mirrors': '[{"id": "y"}]',
      'settings-properties': '[{"k": "v"}]',
      'settings-path': '/custom/settings.xml',
      'settings-override': 'false'
    })

    await run()

    expect(writeSettings).toHaveBeenCalledWith({
      servers: '[{"id": "x"}]',
      mirrors: '[{"id": "y"}]',
      properties: '[{"k": "v"}]',
      path: '/custom/settings.xml',
      override: false
    })
  })

  it('Defaults settings-override to true', async () => {
    await run()

    expect(writeSettings).toHaveBeenCalledWith({
      servers: '',
      mirrors: '',
      properties: '',
      path: '',
      override: true
    })
  })

  it('Sets a failed status when the installation fails', async () => {
    installMaven.mockClear().mockRejectedValueOnce(new Error('download failed'))

    await run()

    expect(core.setFailed).toHaveBeenCalledWith('download failed')
    expect(core.setOutput).not.toHaveBeenCalled()
  })

  it('Sets a failed status when writing the settings fails', async () => {
    writeSettings
      .mockClear()
      .mockRejectedValueOnce(
        new Error('Invalid JSON in the settings-servers input: x')
      )

    await run()

    expect(core.setFailed).toHaveBeenCalledWith(
      'Invalid JSON in the settings-servers input: x'
    )
    expect(core.setOutput).not.toHaveBeenCalled()
  })
})
