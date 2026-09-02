/**
 * Unit tests for the Maven installer, src/installer.ts
 */
import { jest } from '@jest/globals'
import * as core from '../__fixtures__/core.js'
import * as exec from '../__fixtures__/exec.js'
import * as toolCache from '../__fixtures__/tool-cache.js'

// Mocks should be declared before the module being tested is imported.
jest.unstable_mockModule('@actions/core', () => core)
jest.unstable_mockModule('@actions/exec', () => exec)
jest.unstable_mockModule('@actions/tool-cache', () => toolCache)

// The module being tested should be imported dynamically. This ensures that the
// mocks are used in place of any actual dependencies.
const { installMaven } = await import('../src/installer.js')

const mvnVersionOutput = (version: string, home: string): string =>
  [
    `Apache Maven ${version} (2bdd9fddda4b155ebf8000e807eb73fd829a51d5)`,
    `Maven home: ${home}`,
    'Java version: 25.0.4.1, vendor: Eclipse Adoptium'
  ].join('\n')

describe('installer.ts', () => {
  beforeEach(() => {
    // Default: mvn is not on the PATH.
    exec.getExecOutput.mockRejectedValue(
      new Error('Unable to locate executable file: mvn')
    )
  })

  afterEach(() => {
    jest.resetAllMocks()
  })

  it('Returns the cached installation when available', async () => {
    toolCache.find.mockReturnValueOnce('/tool-cache/maven/3.9.16/arm64')

    await expect(installMaven('3.9.16')).resolves.toBe(
      '/tool-cache/maven/3.9.16/arm64'
    )

    expect(toolCache.downloadTool).not.toHaveBeenCalled()
    expect(toolCache.cacheDir).not.toHaveBeenCalled()
  })

  it('Uses a matching preinstalled Maven by default', async () => {
    exec.getExecOutput.mockResolvedValueOnce({
      exitCode: 0,
      stdout: mvnVersionOutput('3.9.16', '/usr/share/apache-maven-3.9.16'),
      stderr: ''
    })

    await expect(installMaven('3.9.16')).resolves.toBe(
      '/usr/share/apache-maven-3.9.16'
    )

    expect(toolCache.downloadTool).not.toHaveBeenCalled()
    expect(toolCache.cacheDir).not.toHaveBeenCalled()
  })

  it('Fails on a preinstalled Maven when skip-if-installed is false', async () => {
    exec.getExecOutput.mockResolvedValueOnce({
      exitCode: 0,
      stdout: mvnVersionOutput('3.9.16', '/usr/share/apache-maven-3.9.16'),
      stderr: ''
    })

    await expect(
      installMaven('3.9.16', { skipIfInstalled: false })
    ).rejects.toThrow(
      'Maven 3.9.16 is already installed at /usr/share/apache-maven-3.9.16 and skip-if-installed is false. ' +
        'Remove Maven from the runner image, or set skip-if-installed to true.'
    )

    expect(toolCache.find).not.toHaveBeenCalled()
    expect(toolCache.downloadTool).not.toHaveBeenCalled()
  })

  it('Downloads when the preinstalled version differs', async () => {
    toolCache.find.mockReturnValueOnce('')
    exec.getExecOutput.mockResolvedValueOnce({
      exitCode: 0,
      stdout: mvnVersionOutput('3.8.8', '/usr/share/apache-maven-3.8.8'),
      stderr: ''
    })
    toolCache.downloadTool.mockResolvedValueOnce('/tmp/maven.tar.gz')
    toolCache.extractTar.mockResolvedValueOnce('/tmp/extracted')
    toolCache.cacheDir.mockResolvedValueOnce('/tool-cache/maven/3.9.16/arm64')

    await expect(installMaven('3.9.16')).resolves.toBe(
      '/tool-cache/maven/3.9.16/arm64'
    )

    expect(toolCache.downloadTool).toHaveBeenCalled()
  })

  it('Downloads and caches Maven when mvn is not on the PATH', async () => {
    toolCache.find.mockReturnValueOnce('')
    toolCache.downloadTool.mockResolvedValueOnce('/tmp/maven.tar.gz')
    toolCache.extractTar.mockResolvedValueOnce('/tmp/extracted')
    toolCache.cacheDir.mockResolvedValueOnce('/tool-cache/maven/3.9.16/arm64')

    await expect(installMaven('3.9.16')).resolves.toBe(
      '/tool-cache/maven/3.9.16/arm64'
    )

    expect(toolCache.downloadTool).toHaveBeenCalledWith(
      'https://archive.apache.org/dist/maven/maven-3/3.9.16/binaries/apache-maven-3.9.16-bin.tar.gz',
      undefined,
      undefined
    )
    expect(toolCache.extractTar).toHaveBeenCalledWith('/tmp/maven.tar.gz')
    expect(toolCache.cacheDir).toHaveBeenCalledWith(
      '/tmp/extracted/apache-maven-3.9.16',
      'maven',
      '3.9.16'
    )
  })

  it('Downloads from the mirror with a bearer token when configured', async () => {
    toolCache.find.mockReturnValueOnce('')
    toolCache.downloadTool.mockResolvedValueOnce('/tmp/maven.tar.gz')
    toolCache.extractTar.mockResolvedValueOnce('/tmp/extracted')
    toolCache.cacheDir.mockResolvedValueOnce('/tool-cache/maven/3.9.16/arm64')

    await installMaven('3.9.16', {
      mirrorUrl: 'https://mirror.example.com/maven/',
      mirrorToken: 'secret-token'
    })

    expect(toolCache.downloadTool).toHaveBeenCalledWith(
      'https://mirror.example.com/maven/org/apache/maven/apache-maven/3.9.16/apache-maven-3.9.16-bin.tar.gz',
      undefined,
      'Bearer secret-token'
    )
  })

  it('Downloads from the mirror without a token when none is given', async () => {
    toolCache.find.mockReturnValueOnce('')
    toolCache.downloadTool.mockResolvedValueOnce('/tmp/maven.tar.gz')
    toolCache.extractTar.mockResolvedValueOnce('/tmp/extracted')
    toolCache.cacheDir.mockResolvedValueOnce('/tool-cache/maven/3.9.16/arm64')

    await installMaven('3.9.16', {
      mirrorUrl: 'https://mirror.example.com/maven'
    })

    expect(toolCache.downloadTool).toHaveBeenCalledWith(
      'https://mirror.example.com/maven/org/apache/maven/apache-maven/3.9.16/apache-maven-3.9.16-bin.tar.gz',
      undefined,
      undefined
    )
  })

  it('Rejects an invalid version', async () => {
    await expect(installMaven('latest')).rejects.toThrow(
      'Invalid Maven version "latest". Expected a full version such as 3.9.16.'
    )

    expect(exec.getExecOutput).not.toHaveBeenCalled()
    expect(toolCache.find).not.toHaveBeenCalled()
    expect(toolCache.downloadTool).not.toHaveBeenCalled()
  })
})
