/**
 * Unit tests for the settings.xml generation, src/settings.ts
 *
 * File writes are real, against a temporary directory. Every test passes an
 * explicit path, so the real $HOME/.m2/settings.xml is never touched.
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
const { writeSettings } = await import('../src/settings.js')

describe('settings.ts', () => {
  let workDir: string
  let settingsPath: string

  beforeEach(async () => {
    workDir = await fs.mkdtemp(path.join(os.tmpdir(), 'setup-maven-settings-'))
    settingsPath = path.join(workDir, 'm2', 'settings.xml')
  })

  afterEach(async () => {
    await fs.rm(workDir, { recursive: true, force: true })
    jest.resetAllMocks()
  })

  it('Writes servers, mirrors, and properties', async () => {
    const written = await writeSettings({
      servers:
        '[{"id": "remote", "username": "oauth2accesstoken", "password": "${env.AR_TOKEN}"}]',
      mirrors:
        '[{"id": "remote", "mirrorOf": "central", "url": "https://mirror.example.com/maven"}]',
      properties: '[{"revision": "1.2.3"}]',
      path: settingsPath
    })

    expect(written).toBe(settingsPath)
    await expect(fs.readFile(settingsPath, 'utf8')).resolves.toBe(
      [
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd">',
        '<interactiveMode>false</interactiveMode>',
        '<servers><server><id>remote</id><username>oauth2accesstoken</username><password>${env.AR_TOKEN}</password></server></servers>',
        '<mirrors><mirror><id>remote</id><mirrorOf>central</mirrorOf><url>https://mirror.example.com/maven</url></mirror></mirrors>',
        '<profiles><profile><id>_properties_</id><activation><activeByDefault>true</activeByDefault></activation><properties><revision>1.2.3</revision></properties></profile></profiles>',
        '</settings>',
        ''
      ].join('\n')
    )
    expect(core.saveState).toHaveBeenCalledWith('settingsPath', settingsPath)
  })

  it('Renders nested objects and escapes special characters', async () => {
    await writeSettings({
      servers:
        '[{"id": "x", "password": "a&b<c>d\\"e\'f", "configuration": {"httpConfiguration": {"all": {"usePreemptive": "true"}}}}]',
      path: settingsPath
    })

    const content = await fs.readFile(settingsPath, 'utf8')
    expect(content).toContain(
      '<password>a&amp;b&lt;c&gt;d&quot;e&apos;f</password>'
    )
    expect(content).toContain(
      '<configuration><httpConfiguration><all><usePreemptive>true</usePreemptive></all></httpConfiguration></configuration>'
    )
  })

  it('Writes nothing when no settings input is set', async () => {
    await expect(writeSettings({ path: settingsPath })).resolves.toBeNull()

    await expect(fs.access(settingsPath)).rejects.toThrow()
    expect(core.saveState).not.toHaveBeenCalled()
  })

  it('Keeps an existing file when override is false', async () => {
    await fs.mkdir(path.dirname(settingsPath), { recursive: true })
    await fs.writeFile(settingsPath, 'original')

    const written = await writeSettings({
      mirrors: '[{"id": "x", "mirrorOf": "central", "url": "u"}]',
      path: settingsPath,
      override: false
    })

    expect(written).toBeNull()
    await expect(fs.readFile(settingsPath, 'utf8')).resolves.toBe('original')
  })

  it('Overwrites an existing file by default', async () => {
    await fs.mkdir(path.dirname(settingsPath), { recursive: true })
    await fs.writeFile(settingsPath, 'original')

    await writeSettings({
      mirrors: '[{"id": "x", "mirrorOf": "central", "url": "u"}]',
      path: settingsPath
    })

    await expect(fs.readFile(settingsPath, 'utf8')).resolves.toContain(
      '<mirrorOf>central</mirrorOf>'
    )
  })

  it('Rejects invalid JSON naming the input', async () => {
    await expect(
      writeSettings({ servers: 'not json', path: settingsPath })
    ).rejects.toThrow(/Invalid JSON in the settings-servers input/)
  })

  it('Rejects JSON that is not an array', async () => {
    await expect(
      writeSettings({ mirrors: '{"id": "x"}', path: settingsPath })
    ).rejects.toThrow('The settings-mirrors input must be a JSON array.')
  })
})
